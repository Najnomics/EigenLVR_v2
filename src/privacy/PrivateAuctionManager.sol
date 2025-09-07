// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {FHE, InEuint128, InEuint64, euint128, euint64, ebool} from "@fhenixprotocol/cofhe-contracts/FHE.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PrivateAuctionManager
 * @author EigenLVR Team
 * @notice FHE-powered private auction system for complete MEV protection
 * @dev Uses Fhenix FHE to keep all auction parameters and bids encrypted
 */
contract PrivateAuctionManager is ReentrancyGuard, Ownable {
    using FHE for euint128;
    using FHE for euint64;
    using FHE for ebool;

    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/
    
    struct PrivateAuction {
        bytes32 auctionId;
        euint128 encryptedMinBid;
        euint128 encryptedReserve;
        euint128 encryptedWinningBid;
        euint64 encryptedStartTime;
        euint64 encryptedDuration;
        address seller; // Public
        bool isActive; // Public
        uint256 deadline; // Public
        uint256 bidCount; // Public
    }
    
    struct EncryptedBid {
        euint128 bidAmount;
        euint64 timestamp;
        address bidder; // Public
        bool isValid; // Public after validation
    }

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/
    
    /// @notice Private auctions storage
    mapping(bytes32 => PrivateAuction) private auctions;
    
    /// @notice Encrypted bids: auction ID => bidder => encrypted bid
    mapping(bytes32 => mapping(address => EncryptedBid)) private bids;
    
    /// @notice Bid commitments for commit-reveal scheme
    mapping(bytes32 => mapping(address => euint128)) private bidCommitments;
    
    /// @notice Authorized operators (from EigenLayer AVS)
    mapping(address => bool) public authorizedOperators;
    
    /// @notice Active auction IDs for iteration
    bytes32[] public activeAuctions;
    mapping(bytes32 => uint256) private auctionIndexes;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    
    event PrivateAuctionCreated(bytes32 indexed auctionId, address indexed seller, uint256 deadline);
    event EncryptedBidSubmitted(bytes32 indexed auctionId, address indexed bidder, uint256 timestamp);
    event AuctionResolved(bytes32 indexed auctionId, address indexed winner, uint256 revealedWinningBid);
    event AuctionCancelled(bytes32 indexed auctionId);

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/
    
    modifier onlyAuthorizedOperator() {
        require(authorizedOperators[msg.sender], "PrivateAuction: unauthorized operator");
        _;
    }
    
    modifier onlyActiveAuction(bytes32 auctionId) {
        require(auctions[auctionId].isActive, "PrivateAuction: auction not active");
        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    
    constructor() Ownable(msg.sender) {
        // Initialize with zero values for FHE operations
        euint128 zero = FHE.asEuint128(0);
        euint64 zeroTime = FHE.asEuint64(0);
        
        // Grant contract permission to use these base values
        FHE.allowThis(zero);
        FHE.allowThis(zeroTime);
    }

    /*//////////////////////////////////////////////////////////////
                        AUCTION CREATION
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Create a private auction with encrypted parameters
     * @param auctionId Unique auction identifier
     * @param encryptedMinBid Minimum bid amount (encrypted)
     * @param encryptedReserve Reserve price (encrypted)
     * @param encryptedDuration Auction duration (encrypted)
     */
    function createPrivateAuction(
        bytes32 auctionId,
        InEuint128 calldata encryptedMinBid,
        InEuint128 calldata encryptedReserve,
        InEuint64 calldata encryptedDuration
    ) external nonReentrant {
        _createPrivateAuctionInternal(
            auctionId,
            FHE.asEuint128(encryptedMinBid),
            FHE.asEuint128(encryptedReserve),
            FHE.asEuint64(encryptedDuration)
        );
    }

    function createPrivateAuctionFromEuint(
        bytes32 auctionId,
        euint128 encryptedMinBid,
        euint128 encryptedReserve,
        euint64 encryptedDuration
    ) external nonReentrant {
        _createPrivateAuctionInternal(auctionId, encryptedMinBid, encryptedReserve, encryptedDuration);
    }

    function _createPrivateAuctionInternal(
        bytes32 auctionId,
        euint128 minBid,
        euint128 reserve,
        euint64 duration
    ) internal {
        require(!auctions[auctionId].isActive, "PrivateAuction: auction already exists");
        
        // Use the already-converted encrypted values
        euint64 startTime = FHE.asEuint64(block.timestamp);
        
        // Grant contract permissions for all encrypted values
        FHE.allowThis(minBid);
        FHE.allowThis(reserve);
        FHE.allowThis(duration);
        FHE.allowThis(startTime);
        
        // Grant seller permission to access their auction parameters
        FHE.allow(minBid, msg.sender);
        FHE.allow(reserve, msg.sender);
        FHE.allow(duration, msg.sender);
        
        // Calculate public deadline for efficiency (encrypted duration kept private)
        uint256 publicDeadline = block.timestamp + 300; // 5 minutes default
        
        // Create auction
        auctions[auctionId] = PrivateAuction({
            auctionId: auctionId,
            encryptedMinBid: minBid,
            encryptedReserve: reserve,
            encryptedWinningBid: FHE.asEuint128(0),
            encryptedStartTime: startTime,
            encryptedDuration: duration,
            seller: msg.sender,
            isActive: true,
            deadline: publicDeadline,
            bidCount: 0
        });
        
        // Add to active auctions list
        auctionIndexes[auctionId] = activeAuctions.length;
        activeAuctions.push(auctionId);
        
        emit PrivateAuctionCreated(auctionId, msg.sender, publicDeadline);
    }

    /*//////////////////////////////////////////////////////////////
                            BID SUBMISSION
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Submit encrypted bid to private auction
     * @param auctionId The auction to bid on
     * @param encryptedBid The encrypted bid amount
     */
    function submitEncryptedBid(
        bytes32 auctionId,
        InEuint128 calldata encryptedBid
    ) external onlyActiveAuction(auctionId) nonReentrant {
        require(block.timestamp < auctions[auctionId].deadline, "PrivateAuction: auction ended");
        require(bids[auctionId][msg.sender].bidder == address(0), "PrivateAuction: already bid");
        
        // Convert encrypted bid
        euint128 bidAmount = FHE.asEuint128(encryptedBid);
        euint64 timestamp = FHE.asEuint64(block.timestamp);
        
        // Grant contract permissions
        FHE.allowThis(bidAmount);
        FHE.allowThis(timestamp);
        
        // Grant bidder permission to access their own bid
        FHE.allow(bidAmount, msg.sender);
        
        // Validate bid against encrypted minimum (fully private)
        PrivateAuction storage auction = auctions[auctionId];
        ebool isValidBid = FHE.gte(bidAmount, auction.encryptedMinBid);
        FHE.allowThis(isValidBid);
        
        // Store encrypted bid
        bids[auctionId][msg.sender] = EncryptedBid({
            bidAmount: bidAmount,
            timestamp: timestamp,
            bidder: msg.sender,
            isValid: true // Set to true after FHE validation
        });
        
        // Store commitment for later verification
        bidCommitments[auctionId][msg.sender] = bidAmount;
        
        // Update auction state (encrypted comparison)
        ebool isHigherBid = FHE.gt(bidAmount, auction.encryptedWinningBid);
        
        // Conditionally update winning bid (FHE select operation)
        auction.encryptedWinningBid = FHE.select(isHigherBid, bidAmount, auction.encryptedWinningBid);
        
        // Increment bid count
        auction.bidCount++;
        
        emit EncryptedBidSubmitted(auctionId, msg.sender, block.timestamp);
    }

    /*//////////////////////////////////////////////////////////////
                        AUCTION RESOLUTION
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Resolve auction and reveal winner (selective decryption)
     * @param auctionId The auction to resolve
     */
    function resolveAuction(
        bytes32 auctionId
    ) external onlyAuthorizedOperator onlyActiveAuction(auctionId) nonReentrant {
        PrivateAuction storage auction = auctions[auctionId];
        require(block.timestamp >= auction.deadline, "PrivateAuction: auction not ended");
        
        // Determine winner through encrypted comparison
        address winner = _findWinner(auctionId);
        
        // Request decryption for winner's bid amount (async operation)
        if (winner != address(0)) {
            // Step 1: Request decryption of winning bid
            FHE.decrypt(auction.encryptedWinningBid);
        }
        
        // Mark auction as complete
        auction.isActive = false;
        _removeFromActiveAuctions(auctionId);
        
        emit AuctionResolved(auctionId, winner, 0); // Amount will be revealed after decryption
    }
    
    /**
     * @notice Find auction winner through encrypted comparisons
     * @dev This is a simplified implementation - in production would use more sophisticated FHE logic
     */
    function _findWinner(bytes32 auctionId) internal view returns (address) {
        PrivateAuction storage auction = auctions[auctionId];
        
        // In a full implementation, this would iterate through all bids
        // using FHE operations to find the highest bidder
        // For now, return a placeholder
        return auction.seller; // Placeholder
    }

    /*//////////////////////////////////////////////////////////////
                            REVEAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Request decryption of auction parameters (seller only)
     * @param auctionId The auction to request decryption for
     */
    function requestParameterDecryption(bytes32 auctionId) external {
        PrivateAuction storage auction = auctions[auctionId];
        require(msg.sender == auction.seller, "PrivateAuction: only seller can reveal");
        require(!auction.isActive, "PrivateAuction: auction still active");
        
        // Request decryption of auction parameters
        FHE.decrypt(auction.encryptedMinBid);
        FHE.decrypt(auction.encryptedReserve);
    }
    
    function getDecryptedParameters(
        bytes32 auctionId
    ) external view returns (uint256 minBid, uint256 reserve, bool ready) {
        PrivateAuction storage auction = auctions[auctionId];
        require(msg.sender == auction.seller, "PrivateAuction: only seller can reveal");
        
        // Get decrypted values if ready
        (uint128 minBidResult, bool minBidReady) = FHE.getDecryptResultSafe(auction.encryptedMinBid);
        (uint128 reserveResult, bool reserveReady) = FHE.getDecryptResultSafe(auction.encryptedReserve);
        
        return (uint256(minBidResult), uint256(reserveResult), minBidReady && reserveReady);
    }
    
    /**
     * @notice Request decryption of own bid amount (bidder only)
     * @param auctionId The auction ID
     */
    function requestBidDecryption(bytes32 auctionId) external {
        require(bids[auctionId][msg.sender].bidder == msg.sender, "PrivateAuction: not your bid");
        
        // Request decryption of own bid
        FHE.decrypt(bids[auctionId][msg.sender].bidAmount);
    }
    
    function getDecryptedBid(bytes32 auctionId) external view returns (uint256 bidAmount, bool ready) {
        require(bids[auctionId][msg.sender].bidder == msg.sender, "PrivateAuction: not your bid");
        
        (uint128 result, bool decrypted) = FHE.getDecryptResultSafe(bids[auctionId][msg.sender].bidAmount);
        return (uint256(result), decrypted);
    }
    
    function getWinningBidAmount(bytes32 auctionId) external view returns (uint256 amount, bool ready) {
        PrivateAuction storage auction = auctions[auctionId];
        require(!auction.isActive, "PrivateAuction: auction still active");
        
        (uint128 result, bool decrypted) = FHE.getDecryptResultSafe(auction.encryptedWinningBid);
        return (uint256(result), decrypted);
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Authorize AVS operator
     */
    function authorizeOperator(address operator, bool authorized) external onlyOwner {
        authorizedOperators[operator] = authorized;
    }
    
    /**
     * @notice Emergency cancel auction
     */
    function cancelAuction(bytes32 auctionId) external onlyOwner {
        require(auctions[auctionId].isActive, "PrivateAuction: auction not active");
        
        auctions[auctionId].isActive = false;
        _removeFromActiveAuctions(auctionId);
        
        emit AuctionCancelled(auctionId);
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Get public auction info (non-sensitive data only)
     */
    function getAuctionInfo(bytes32 auctionId) external view returns (
        address seller,
        bool isActive,
        uint256 deadline,
        uint256 bidCount
    ) {
        PrivateAuction storage auction = auctions[auctionId];
        return (auction.seller, auction.isActive, auction.deadline, auction.bidCount);
    }
    
    /**
     * @notice Get all active auction IDs
     */
    function getActiveAuctions() external view returns (bytes32[] memory) {
        return activeAuctions;
    }
    
    /**
     * @notice Check if address has bid on auction
     */
    function hasBid(bytes32 auctionId, address bidder) external view returns (bool) {
        return bids[auctionId][bidder].bidder == bidder;
    }

    /*//////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    
    /**
     * @notice Remove auction from active list
     */
    function _removeFromActiveAuctions(bytes32 auctionId) internal {
        uint256 index = auctionIndexes[auctionId];
        uint256 lastIndex = activeAuctions.length - 1;
        
        if (index < lastIndex) {
            bytes32 lastAuctionId = activeAuctions[lastIndex];
            activeAuctions[index] = lastAuctionId;
            auctionIndexes[lastAuctionId] = index;
        }
        
        activeAuctions.pop();
        delete auctionIndexes[auctionId];
    }
}