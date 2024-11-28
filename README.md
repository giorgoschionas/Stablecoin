# DeFi Stablecoin Project

## Deployed at 
link 

## About
This project is for educational purposes. It is meant to be an algorithmic stablecoin where users can deposit WETH and WBTC in exchange for a token (DSC) that will be pegged to the USD.


## Stability Mechanism (Minting): Algorithmic (Decentralized)
   - People can only mint the stablecoin with enough collateral (overcollateralized)

# Getting Started

## Requirements
   - [foundry](https://getfoundry.sh/)

## Quickstart
```bash
git clone https://github.com/giorgoschionas/Stablecoin.git 
cd Stablecoin
forge build
```

# Testing
   - We run Integration and Fuzzing tests
```bash
forge test
```
## Test Coverage
```bash
forge coverage
```
and for coverage based testing:
```bash
forge coverage --report debug
```

# Deployment to a testnet or mainnet
   1. Setup environment variables
Set your `SEPOLIA_RPC_URL` and `PRIVATE_KEY` as environment variables. You can add them to a `.env` file.

