# Wallet Integration

This document is designed for wallet providers
aiming to integrate with the Babylon Phase-2 Testnet (testnet-5).

Phase-2 marks a significant evolution from Phase-1,
in which the Babylon testnet transitions from a lock-only network
to the launch of a test Babylon PoS blockchain,
built using the Cosmos SDK and secured by mainnet Bitcoin.
This testnet will allow Phase-1 testnet stakers to utilise
their mainnet Bitcoin stakes to secure the test Babylon chain.
Additionally, new stakers will be able to join and contribute.

During Phase-1,
wallet providers only needed to interact with the Bitcoin network
to enable staking, unbonding, and withdrawal
transactions. Phase-2, however, introduces new requirements
for wallets to support both Bitcoin staking and Babylon blockchain
operations. 

Wallets can participate in the phase-2 testnet in
the following ways:
1. **Native wallet support of the Babylon testnet blockchain**:
   Enable native support for the Babylon testnet blockchain, including
   functionality for managing test token balances, executing transfers,
   and facilitating staking operations.
   * For detailed integration instructions, 
     refer to the [Babylon Wallet Integration guide](./babylon-wallet.md)
2. **Support of Bitcoin staking**: Participate in Bitcoin staking
   by integrating with a web application or by natively integrating
   Bitcoin staking functionality directly to your wallet,
   whether it's a browser extension, mobile app, or hardware wallet.
   * For detailed instructions,
     refer to the [Bitcoin Staking Integration guide](./bitcoin-staking.md)
