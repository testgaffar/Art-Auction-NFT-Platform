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
## deploy logs in remix 

[block:9504398 txIndex:-]from: 0xd37...e5b2bto: NFTAuction.(constructor)value: 0 weidata: 0x608...15180logs: 2hash: 0x1a3...dd5c5
status	0x1 Transaction mined and execution succeed
transaction hash	0x88b5ae4266581f1298fbd7a1f45e83c2ff955c674e375d837cef4f291c9f760f
block hash	0x1a3524dfbdada8a6e7058fe7e9093091c33ff3ca9b7ae9d8117d748d082dd5c5
block number	9504398
contract address	0x70eb443cc5347982fac62fc19ea388c82d7aaceb
from	0xd3761B4E38C09119266Ce2d74868a80e3c3e5B2b
to	NFTAuction.(constructor)
gas	2567991 gas
transaction cost	2546613 gas 
input	0x608...15180
decoded input	{
	"address _nftContract": "0xa124bEec76eB93640ac0af73F5713e107dd285db",
	"uint256 _tokenId": "1",
	"uint256 _startingPrice": "1000000000000000000",
	"uint256 _reservePrice": "2000000000000000000",
	"uint256 _minBidIncrement": "100000000000000000",
	"uint256 _duration": "86400"
}
decoded output	 - 
logs	[
	{
		"from": "0x70eb443cc5347982fac62fc19ea388c82d7aaceb",
		"topic": "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0",
		"event": "OwnershipTransferred",
		"args": {
			"0": "0x0000000000000000000000000000000000000000",
			"1": "0xd3761B4E38C09119266Ce2d74868a80e3c3e5B2b"
		}
	},
	{
		"from": "0x70eb443cc5347982fac62fc19ea388c82d7aaceb",
		"topic": "0x3b7b4c5af27f2d215ab04ff752eb66d4d2500c6584590ed58288a4275196886d",
		"event": "AuctionCreated",
		"args": {
			"0": "0xd3761B4E38C09119266Ce2d74868a80e3c3e5B2b",
			"1": "0xa124bEec76eB93640ac0af73F5713e107dd285db",
			"2": "1",
			"3": "1000000000000000000",
			"4": "2000000000000000000",
			"5": "1761828968"
		}
	}
]
raw logs	[
  {
    "address": "0x70eb443cc5347982fac62fc19ea388c82d7aaceb",
    "topics": [
      "0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0",
      "0x0000000000000000000000000000000000000000000000000000000000000000",
      "0x000000000000000000000000d3761b4e38c09119266ce2d74868a80e3c3e5b2b"
    ],
    "data": "0x",
    "blockNumber": "0x91068e",
    "transactionHash": "0x88b5ae4266581f1298fbd7a1f45e83c2ff955c674e375d837cef4f291c9f760f",
    "transactionIndex": "0x0",
    "blockHash": "0x1a3524dfbdada8a6e7058fe7e9093091c33ff3ca9b7ae9d8117d748d082dd5c5",
    "logIndex": "0x0",
    "removed": false
  },
  {
    "address": "0x70eb443cc5347982fac62fc19ea388c82d7aaceb",
    "topics": [
      "0x3b7b4c5af27f2d215ab04ff752eb66d4d2500c6584590ed58288a4275196886d",
      "0x000000000000000000000000d3761b4e38c09119266ce2d74868a80e3c3e5b2b",
      "0x000000000000000000000000a124beec76eb93640ac0af73f5713e107dd285db",
      "0x0000000000000000000000000000000000000000000000000000000000000001"
    ],
    "data": "0x0000000000000000000000000000000000000000000000000de0b6b3a76400000000000000000000000000000000000000000000000000001bc16d674ec800000000000000000000000000000000000000000000000000000000000069036068",
    "blockNumber": "0x91068e",
    "transactionHash": "0x88b5ae4266581f1298fbd7a1f45e83c2ff955c674e375d837cef4f291c9f760f",
    "transactionIndex": "0x0",
    "blockHash": "0x1a3524dfbdada8a6e7058fe7e9093091c33ff3ca9b7ae9d8117d748d082dd5c5",
    "logIndex": "0x1",
    "removed": false
  }
]
Verification process started...
Verifying with Sourcify...
Sourcify verification successful.
https://repo.sourcify.dev/1114/0x70eb443cc5347982Fac62Fc19eA388c82d7aACEb/

## License

MIT License
