package crosschain

import (
	"context"
	"fmt"
	"math/big"
	"sync"
	"time"

	"github.com/Layr-Labs/eigensdk-go/logging"
)

type Monitor struct {
	config Config
	logger logging.Logger
	
	// Price data: chainId => pair => price
	prices      map[uint64]map[string]*big.Int
	pricesMutex sync.RWMutex
}

type Config struct {
	SupportedChains []uint64          `json:"supported_chains"`
	RpcUrls         map[string]string `json:"rpc_urls"`
	UpdateInterval  time.Duration     `json:"update_interval"`
}

type LVROpportunity struct {
	SourceChain uint64   `json:"sourceChain"`
	TargetChain uint64   `json:"targetChain"`
	ProfitBps   uint64   `json:"profitBps"`
	Volume      *big.Int `json:"volume"`
}

func NewMonitor(config Config, logger logging.Logger) (*Monitor, error) {
	return &Monitor{
		config: config,
		logger: logger.With("component", "cross-chain-monitor"),
		prices: make(map[uint64]map[string]*big.Int),
	}, nil
}

func (m *Monitor) Start(ctx context.Context) error {
	m.logger.Info("Starting cross-chain price monitor")
	
	ticker := time.NewTicker(m.config.UpdateInterval)
	defer ticker.Stop()
	
	for {
		select {
		case <-ctx.Done():
			return nil
		case <-ticker.C:
			m.updatePrices()
		}
	}
}

func (m *Monitor) updatePrices() {
	m.logger.Debug("Updating cross-chain prices")
	
	// Simulate price updates for supported chains
	for _, chainId := range m.config.SupportedChains {
		m.updateChainPrices(chainId)
	}
}

func (m *Monitor) updateChainPrices(chainId uint64) {
	m.pricesMutex.Lock()
	defer m.pricesMutex.Unlock()
	
	if m.prices[chainId] == nil {
		m.prices[chainId] = make(map[string]*big.Int)
	}
	
	// Simulate ETH/USDC prices with slight variations
	basePrice := big.NewInt(3000e18) // $3000
	variation := int64(chainId) % 50  // Up to $50 variation
	
	m.prices[chainId]["ETH/USDC"] = new(big.Int).Add(basePrice, big.NewInt(variation*1e18))
	
	m.logger.Debug("Updated chain prices", 
		"chainId", chainId, 
		"ethUsdcPrice", m.prices[chainId]["ETH/USDC"].String(),
	)
}

func (m *Monitor) GetLatestPrices() (map[uint64]map[string]*big.Int, error) {
	m.pricesMutex.RLock()
	defer m.pricesMutex.RUnlock()
	
	// Deep copy to avoid data races
	result := make(map[uint64]map[string]*big.Int)
	for chainId, chainPrices := range m.prices {
		result[chainId] = make(map[string]*big.Int)
		for pair, price := range chainPrices {
			result[chainId][pair] = new(big.Int).Set(price)
		}
	}
	
	return result, nil
}

func (m *Monitor) DetectArbitrageOpportunity(pair string, minProfitBps uint64) (*LVROpportunity, error) {
	m.pricesMutex.RLock()
	defer m.pricesMutex.RUnlock()
	
	var bestOpportunity *LVROpportunity
	
	for sourceChain, sourcePrices := range m.prices {
		sourcePrice, exists := sourcePrices[pair]
		if !exists {
			continue
		}
		
		for targetChain, targetPrices := range m.prices {
			if sourceChain == targetChain {
				continue
			}
			
			targetPrice, exists := targetPrices[pair]
			if !exists {
				continue
			}
			
			// Calculate profit in basis points
			var profitBps uint64
			if sourcePrice.Cmp(targetPrice) > 0 {
				diff := new(big.Int).Sub(sourcePrice, targetPrice)
				profitBps = uint64(new(big.Int).Div(
					new(big.Int).Mul(diff, big.NewInt(10000)),
					targetPrice,
				).Uint64())
			} else {
				diff := new(big.Int).Sub(targetPrice, sourcePrice)
				profitBps = uint64(new(big.Int).Div(
					new(big.Int).Mul(diff, big.NewInt(10000)),
					sourcePrice,
				).Uint64())
			}
			
			if profitBps >= minProfitBps {
				opportunity := &LVROpportunity{
					SourceChain: sourceChain,
					TargetChain: targetChain,
					ProfitBps:   profitBps,
					Volume:      big.NewInt(10e18), // 10 ETH example volume
				}
				
				if bestOpportunity == nil || profitBps > bestOpportunity.ProfitBps {
					bestOpportunity = opportunity
				}
			}
		}
	}
	
	return bestOpportunity, nil
}