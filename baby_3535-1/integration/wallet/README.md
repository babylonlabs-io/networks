# Wallet Integration

This document is designed for wallet providers
aiming to integrate with the Babylon Genesis mainnet (`baby_3536-1`).

Phase-2 marks a significant evolution from Phase-1,
in which the Babylon mainnet transitions from a lock-only network
to the launch of a Babylon Genesis blockchain,
built using the Cosmos SDK and secured by mainnet Bitcoin.
This mainnet will allow Phase-1 mainnet stakers to utilise
their mainnet Bitcoin stakes to secure the Babylon Genesis chain.
Additionally, new stakers will be able to join and contribute.

During Phase-1,
wallet providers only needed to interact with the Bitcoin network
to enable staking, unbonding, and withdrawal
transactions. Phase-2, however, introduces new requirements
for wallets to support both Bitcoin staking and Babylon blockchain
operations. 

Wallets can participate in the Babylon Genesis mainnet in
the following ways:
1. **Native wallet support of the Babylon Genesis blockchain**:
   Enable native support for the Babylon Genesis blockchain, including
   functionality for managing token balances, executing transfers,
   and facilitating staking operations.
   * For detailed integration instructions, 
     refer to the [Babylon Wallet Integration guide](./babylon-wallet.md)
2. **Support of Bitcoin staking**: Participate in Bitcoin staking
   by integrating with a web application or by natively integrating
   Bitcoin staking functionality directly to your wallet,
   whether it's a browser extension, mobile app, or hardware wallet.
   * For detailed instructions,
     refer to the [Bitcoin Staking Integration guide](./bitcoin-staking.md)
