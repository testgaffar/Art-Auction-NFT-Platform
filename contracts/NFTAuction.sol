// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/*
 * @title NFTAuction
 * @dev Manages individual NFT auctions with bidding, refunds, and automatic transfers
 * FIXED VERSION: Transfers NFT after deployment, not in constructor
 */
contract NFTAuction is ReentrancyGuard, Ownable {
    
    // Auction states
    enum AuctionState {
        Created,
        Active,
        Ended,
        Successful,
        Failed,
        Cancelled
    }
    
    // Auction structure
    struct Auction {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 startingPrice;
        uint256 reservePrice;
        uint256 minBidIncrement;
        uint256 startTime;
        uint256 endTime;
        address highestBidder;
        uint256 highestBid;
        AuctionState state;
        bool finalized;
    }
    
    // Platform fee (2.5% = 250/10000)
    uint256 public constant PLATFORM_FEE = 250;
    uint256 public constant FEE_DENOMINATOR = 10000;
    
    // Auction storage
    Auction public auction;
    
    // Mapping to track bids
    mapping(address => uint256) public pendingReturns;
    
    // Events
    event AuctionCreated(
        address indexed seller,
        address indexed nftContract,
        uint256 indexed tokenId,
        uint256 startingPrice,
        uint256 reservePrice,
        uint256 endTime
    );
    
    event AuctionStarted(
        address indexed seller,
        uint256 indexed tokenId
    );
    
    event BidPlaced(
        address indexed bidder,
        uint256 amount,
        uint256 timestamp
    );
    
    event AuctionFinalized(
        address indexed winner,
        uint256 finalPrice,
        AuctionState state
    );
    
    event AuctionCancelled(
        address indexed seller,
        uint256 tokenId
    );
    
    event BidRefunded(
        address indexed bidder,
        uint256 amount
    );
    
    /**
     * @dev Create a new auction
     * @param _nftContract Address of the NFT contract
     * @param _tokenId Token ID of the NFT
     * @param _startingPrice Starting bid price
     * @param _reservePrice Minimum price to sell (0 for no reserve)
     * @param _minBidIncrement Minimum amount to increase bid
     * @param _duration Auction duration in seconds
     */
    constructor(
        address _nftContract,
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _reservePrice,
        uint256 _minBidIncrement,
        uint256 _duration
    ) Ownable(msg.sender) {
        require(_nftContract != address(0), "Invalid NFT contract");
        require(_startingPrice > 0, "Starting price must be greater than 0");
        require(_minBidIncrement > 0, "Min bid increment must be greater than 0");
        require(_duration >= 3600, "Duration must be at least 1 hour");
        require(_duration <= 30 days, "Duration cannot exceed 30 days");
        
        if (_reservePrice > 0) {
            require(_reservePrice >= _startingPrice, "Reserve must be >= starting price");
        }
        
        // Initialize auction in Created state (not Active yet)
        auction = Auction({
            seller: msg.sender,
            nftContract: _nftContract,
            tokenId: _tokenId,
            startingPrice: _startingPrice,
            reservePrice: _reservePrice,
            minBidIncrement: _minBidIncrement,
            startTime: block.timestamp,
            endTime: block.timestamp + _duration,
            highestBidder: address(0),
            highestBid: 0,
            state: AuctionState.Created,
            finalized: false
        });
        
        emit AuctionCreated(
            msg.sender,
            _nftContract,
            _tokenId,
            _startingPrice,
            _reservePrice,
            auction.endTime
        );
    }
    
    /**
     * @dev Start the auction by transferring NFT to contract
     * Must be called after approving this contract to transfer the NFT
     */
    function startAuction() external nonReentrant {
        require(msg.sender == auction.seller, "Only seller can start");
        require(auction.state == AuctionState.Created, "Auction already started");
        
        // Transfer NFT from seller to contract
        IERC721 nft = IERC721(auction.nftContract);
        require(nft.ownerOf(auction.tokenId) == msg.sender, "Caller is not NFT owner");
        nft.transferFrom(msg.sender, address(this), auction.tokenId);
        
        // Activate the auction
        auction.state = AuctionState.Active;
        
        emit AuctionStarted(msg.sender, auction.tokenId);
    }
    
    /**
     * @dev Place a bid on the auction
     */
    function placeBid() external payable nonReentrant {
        require(auction.state == AuctionState.Active, "Auction is not active");
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(msg.sender != auction.seller, "Seller cannot bid on own auction");
        require(msg.value > 0, "Bid must be greater than 0");
        
        uint256 minimumBid;
        
        if (auction.highestBid == 0) {
            // First bid must meet starting price
            minimumBid = auction.startingPrice;
        } else {
            // Subsequent bids must exceed current bid by min increment
            minimumBid = auction.highestBid + auction.minBidIncrement;
        }
        
        require(msg.value >= minimumBid, "Bid too low");
        
        // Refund previous highest bidder
        if (auction.highestBidder != address(0)) {
            pendingReturns[auction.highestBidder] += auction.highestBid;
        }
        
        // Update auction
        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
        
        emit BidPlaced(msg.sender, msg.value, block.timestamp);
    }
    
    /**
     * @dev Withdraw refunded bid
     */
    function withdrawRefund() external nonReentrant {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "No funds to withdraw");
        
        pendingReturns[msg.sender] = 0;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Refund transfer failed");
        
        emit BidRefunded(msg.sender, amount);
    }
    
    /**
     * @dev Finalize the auction after it ends
     */
    function finalizeAuction() external nonReentrant {
        require(auction.state == AuctionState.Active, "Auction is not active");
        require(block.timestamp >= auction.endTime, "Auction has not ended yet");
        require(!auction.finalized, "Auction already finalized");
        
        auction.finalized = true;
        
        // Check if reserve price was met
        bool reserveMet = (auction.reservePrice == 0) || 
                         (auction.highestBid >= auction.reservePrice);
        
        if (auction.highestBidder != address(0) && reserveMet) {
            // Successful auction
            auction.state = AuctionState.Successful;
            
            // Calculate platform fee and seller proceeds
            uint256 platformFee = (auction.highestBid * PLATFORM_FEE) / FEE_DENOMINATOR;
            uint256 sellerProceeds = auction.highestBid - platformFee;
            
            // Transfer NFT to winner
            IERC721(auction.nftContract).transferFrom(
                address(this),
                auction.highestBidder,
                auction.tokenId
            );
            
            // Transfer funds to seller
            (bool sellerSuccess, ) = auction.seller.call{value: sellerProceeds}("");
            require(sellerSuccess, "Seller payment failed");
            
            // Transfer platform fee to owner
            (bool feeSuccess, ) = owner().call{value: platformFee}("");
            require(feeSuccess, "Fee transfer failed");
            
            emit AuctionFinalized(auction.highestBidder, auction.highestBid, AuctionState.Successful);
            
        } else {
            // Failed auction - reserve not met or no bids
            auction.state = AuctionState.Failed;
            
            // Return NFT to seller
            IERC721(auction.nftContract).transferFrom(
                address(this),
                auction.seller,
                auction.tokenId
            );
            
            // Refund highest bidder if any
            if (auction.highestBidder != address(0)) {
                pendingReturns[auction.highestBidder] += auction.highestBid;
            }
            
            emit AuctionFinalized(address(0), 0, AuctionState.Failed);
        }
    }
    
    /**
     * @dev Cancel auction before it starts or before any bids are placed
     */
    function cancelAuction() external nonReentrant {
        require(msg.sender == auction.seller, "Only seller can cancel");
        require(
            auction.state == AuctionState.Created || auction.state == AuctionState.Active,
            "Auction cannot be cancelled"
        );
        require(auction.highestBidder == address(0), "Cannot cancel after bids placed");
        require(!auction.finalized, "Auction already finalized");
        
        auction.state = AuctionState.Cancelled;
        auction.finalized = true;
        
        // Return NFT to seller if it was transferred
        if (auction.state == AuctionState.Active) {
            IERC721(auction.nftContract).transferFrom(
                address(this),
                auction.seller,
                auction.tokenId
            );
        }
        
        emit AuctionCancelled(auction.seller, auction.tokenId);
    }
    
    /**
     * @dev Get auction details
     */
    function getAuctionDetails() external view returns (
        address seller,
        address nftContract,
        uint256 tokenId,
        uint256 startingPrice,
        uint256 reservePrice,
        uint256 minBidIncrement,
        uint256 startTime,
        uint256 endTime,
        address highestBidder,
        uint256 highestBid,
        AuctionState state,
        bool finalized
    ) {
        return (
            auction.seller,
            auction.nftContract,
            auction.tokenId,
            auction.startingPrice,
            auction.reservePrice,
            auction.minBidIncrement,
            auction.startTime,
            auction.endTime,
            auction.highestBidder,
            auction.highestBid,
            auction.state,
            auction.finalized
        );
    }
    
    /**
     * @dev Get time remaining in auction
     */
    function getTimeRemaining() external view returns (uint256) {
        if (block.timestamp >= auction.endTime) {
            return 0;
        }
        return auction.endTime - block.timestamp;
    }
    
    /**
     * @dev Check if auction is active
     */
    function isActive() external view returns (bool) {
        return auction.state == AuctionState.Active && 
               block.timestamp < auction.endTime;
    }
    
    /**
     * @dev Get minimum next bid amount
     */
    function getMinimumBid() external view returns (uint256) {
        if (auction.highestBid == 0) {
            return auction.startingPrice;
        }
        return auction.highestBid + auction.minBidIncrement;
    }
    
    /**
     * @dev Check if reserve price is met
     */
    function isReserveMet() external view returns (bool) {
        if (auction.reservePrice == 0) {
            return true;
        }
        return auction.highestBid >= auction.reservePrice;
    }
}

