package avsregistry

import (
	"github.com/Layr-Labs/eigensdk-go/chainio/clients/eth"
	"github.com/Layr-Labs/eigensdk-go/logging"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"crypto/ecdsa"
)

// AvsRegistryChainReader provides read access to AVS registry contracts
type AvsRegistryChainReader struct {
	registryCoordinator    common.Address
	operatorStateRetriever common.Address
	ethClient             eth.Client
	logger                logging.Logger
}

// AvsRegistryChainWriter provides write access to AVS registry contracts
type AvsRegistryChainWriter struct {
	registryCoordinator    common.Address
	operatorStateRetriever common.Address
	ethClient             eth.Client
	privateKey            *ecdsa.PrivateKey
	logger                logging.Logger
}

func NewAvsRegistryChainReader(
	registryCoordinator common.Address,
	operatorStateRetriever common.Address,
	ethClient eth.Client,
	logger logging.Logger,
) (*AvsRegistryChainReader, error) {
	return &AvsRegistryChainReader{
		registryCoordinator:    registryCoordinator,
		operatorStateRetriever: operatorStateRetriever,
		ethClient:             ethClient,
		logger:                logger,
	}, nil
}

func NewAvsRegistryChainWriter(
	registryCoordinator common.Address,
	operatorStateRetriever common.Address,
	ethClient eth.Client,
	privateKey *ecdsa.PrivateKey,
	logger logging.Logger,
) (*AvsRegistryChainWriter, error) {
	return &AvsRegistryChainWriter{
		registryCoordinator:    registryCoordinator,
		operatorStateRetriever: operatorStateRetriever,
		ethClient:             ethClient,
		privateKey:            privateKey,
		logger:                logger,
	}, nil
}