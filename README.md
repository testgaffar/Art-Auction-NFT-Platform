# Art Auction NFT Platform

A decentralized NFT auction platform where artists can mint and auction their digital art as NFTs, and collectors can bid on them using cryptocurrency.

## Overview

This platform allows artists to create (mint) NFTs of their artwork and put them up for auction. Buyers can place bids, and the highest bidder at the end of the auction wins the NFT. Everything happens on the blockchain - no middlemen needed.

## Features

- **Mint NFTs**: Artists can create NFTs from their digital artwork
- **Create Auctions**: Set starting price, duration, and reserve price
- **Place Bids**: Collectors can bid on active auctions
- **Automatic Winner**: Smart contract automatically transfers NFT to highest bidder
- **Refunds**: Losing bidders get their money back automatically
- **Auction History**: View all past and active auctions
- **NFT Gallery**: Browse all minted NFTs

## Tech Stack

### Smart Contracts (Onchain Core)
- **Solidity**: Smart contract language
- **Hardhat**: Development and testing framework
- **OpenZeppelin**: ERC-721 (NFT) standard implementation
- **Ethers.js**: Blockchain interaction

### Frontend
- **React**: User interface
- **Web3.js / Ethers.js**: Connect to blockchain
- **IPFS**: Store NFT images and metadata
- **MetaMask**: Wallet integration

## Project Structure

```
Art-Auction-NFT-Platform/
├── contracts/              # Smart contracts
│   ├── NFTAuction.sol     # Main auction contract
│   ├── ArtNFT.sol         # NFT contract (ERC-721)
│   └── AuctionFactory.sol # Creates new auctions
├── scripts/               # Deployment scripts
├── test/                  # Contract tests
└── frontend/              # React app
    ├── src/
    │   ├── components/    # UI components
    │   ├── pages/         # Pages
    │   └── utils/         # Web3 helpers
    └── public/
```

## How It Works

### 1. Minting NFTs
- Artist uploads artwork to IPFS
- Artist mints NFT with metadata (title, description, image URL)
- NFT is created on blockchain with unique token ID
- Artist owns the NFT until it's sold

### 2. Creating Auctions
- Artist creates auction for their NFT
- Sets auction parameters:
  - Starting price
  - Minimum bid increment
  - Auction duration (e.g., 7 days)
  - Reserve price (optional minimum to sell)
- NFT is locked in the auction contract

### 3. Bidding Process
- Buyers place bids (must be higher than current bid)
- Each bid locks the bidder's funds in the contract
- Previous bidder gets refunded automatically
- Bids continue until auction ends

### 4. Auction End
- After duration expires, anyone can finalize the auction
- If reserve price met:
  - NFT transfers to highest bidder
  - Funds transfer to artist (minus platform fee)
- If reserve not met:
  - NFT returns to artist
  - Highest bidder gets refunded

## Design Choices

### Why Onchain Only?

**Decentralized**: No central server can go down or censor artists.

**Trustless**: Smart contracts enforce rules automatically - no need to trust the platform.

**Transparent**: All bids and transactions are public and verifiable.

**Ownership**: Artists and collectors truly own their NFTs.

### Security Features

- **Reentrancy Protection**: Prevents hacking attacks
- **Time-locked**: Auctions can't end early
- **Automatic Refunds**: No manual intervention needed
- **Access Control**: Only NFT owner can create auction
- **Bid Validation**: Ensures bids are valid and sufficient

### Smart Contract Architecture

**ArtNFT.sol** (ERC-721)
- Mints new NFTs with unique token IDs
- Stores metadata URI (IPFS link)
- Handles NFT transfers
- Implements standard NFT functions

**NFTAuction.sol**
- Manages single auction lifecycle
- Accepts and tracks bids
- Handles refunds to outbid users
- Transfers NFT and funds at auction end
- Enforces auction rules

**AuctionFactory.sol**
- Creates new auction contracts
- Maintains registry of all auctions
- Allows users to find active auctions
- Emits events for indexing

## Core Functionality

### For Artists
- Mint unlimited NFTs
- Create auctions with custom parameters
- Withdraw earnings after successful auction
- Cancel auction before first bid

### For Collectors
- Browse active auctions
- Place bids on NFTs
- Automatic refunds if outbid
- Receive NFT if winning bid
- View owned NFT collection

### Platform Features
- Commission fee (e.g., 2.5%) on successful sales
- IPFS integration for decentralized storage
- Real-time auction status updates
- Bid history tracking
- Search and filter auctions

## Auction States

1. **Created**: Auction is set up, waiting to start
2. **Active**: Auction is live, accepting bids
3. **Ended**: Time expired, waiting to be finalized
4. **Successful**: Reserve met, NFT sold
5. **Failed**: Reserve not met, NFT returned
6. **Cancelled**: Artist cancelled before first bid

## IPFS Integration

- Artwork images stored on IPFS (decentralized storage)
- NFT metadata stored as JSON on IPFS
- Frontend fetches images from IPFS gateway
- Ensures artwork is permanently accessible

## Why This Approach?

### Pure Onchain Benefits

**No Backend Required**: Everything lives on blockchain and IPFS.

**Censorship Resistant**: No one can take down the platform.

**Global Access**: Anyone with crypto can participate.

**Transparent Fees**: All costs visible in smart contracts.

**Permanent**: NFTs and auctions exist forever on blockchain.

## Future Improvements

- Multi-token auctions (sell bundles)
- English vs Dutch auction types
- Royalties for artists on resales
- Collection-based auctions
- Batch minting for artists
- Buy now option (fixed price)
- Auction extensions (if bid in last minutes)
- 
## Contract Deployment:
 -contract address :0x70eb443cc5347982fac62fc19ea388c82d7aaceb
 <img width="1401" height="704" alt="image" src="https://github.com/user-attachments/assets/69ed5b54-26b2-4b30-9c16-67a1b41dbe02" />




## License

MIT License
