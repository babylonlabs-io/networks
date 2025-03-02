# Deployment Overview for Bitcoin Staking Backend

![Staking Backend System Architecture](./assets/staking-backend-system-detailed.png)

The Babylon Bitcoin Staking system comprises of the following components, organized by type and hosting requirements:

## Component Overview

| Category | Component | Description | Required to Host |
|----------|-----------|-------------|-----------------|
| **Core Infrastructure** | | | |
| | Bitcoin Full Node | Verifies whether staking transactions have been submitted to the Bitcoin network and have the required amount of BTC confirmations. | Yes |
| | Babylon Node | Provides access to the Babylon blockchain for monitoring and interacting with staking-related events. | Yes |
| | MongoDB | Stores BTC Staking transaction data and serves as the central data store for the entire system. | Yes |
| | RabbitMQ | Houses a set of queues containing BTC Staking transactions for reliable message passing between services. | Yes |
| **Primary Services** | | | |
| | Babylon Staking Indexer | Monitors both Babylon and Bitcoin blockchains to track staking-related events, validates transactions, stores data in MongoDB, and forwards events to RabbitMQ. | Yes |
| | Staking API Service | Provides API endpoints for the staking system, processes transaction lifecycles, maintains statistics, and handles unbonding requests. | Yes |
| | Staking Expiry Checker | Periodically checks MongoDB for expired BTC Stake Delegations, transitions eligible delegations to "Unbonded" state, and monitors blockchain events. | Yes |
| | Unbonding Pipeline | Forwards unbonding requests for signing to a Covenant Emulator committee and submits them to the BTC network. | No |
| **Operational Tools & Interfaces** | | | |
| | Covenant Signer | Operated by members of the covenant committee. Receives unbonding transactions and returns the same transactions signed by the covenant emulator's key. | No |
| | Bitcoin Offline Wallet | Stores the Covenant Signer member keys and signs unbonding transactions forwarded by the Covenant Signer. | No |
| | Staking Dashboard | UI that allows for creating BTC Staking transactions. Connects to the API to retrieve information about the system and historical delegations. | No |
| | Global Configuration file | Contains system-wide parameters pertinent to the processed Staking transactions. | Yes |

## Deployment Information

For deployment order and detailed deployment instructions, please refer to the [Deployment Details](./details.md) document.