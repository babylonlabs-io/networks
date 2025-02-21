# Deployment Overview for Bitcoin Staking Backend

![Staking Backend System Architecture](./assets/staking-backend-system-detailed.png)

The Babylon Bitcoin Staking system comprises of the following components:

- **BTC Staking Indexer**: Parses BTC blocks for valid staking, unbonding, and withdrawal transactions, and forwards relevant events to a queueing system, while also persisting them to an on-disk key-value storage.
- **RabbitMQ**: Houses a set of queues containing BTC Staking transactions.
- **Staking API Service**: Consumes BTC Staking transactions from the RabbitMQ queues and stores them in a central data store, additionally accepting unbonding requests.
- **MongoDB**: Stores BTC Staking transaction data.
- **Staking Expiry Checker**: Periodically checks MongoDB for expired BTC Stake Delegations and Unbondings.
- **Unbonding Pipeline**: Forwards unbonding requests for signing to a Covenant Emulator committee and submits them to the BTC network
- **Staking Dashboard**: UI that allows for creating BTC Staking transactions. Connects to the API to retrieve information about the system and historical delegations.
- **Covenant Signer**: Operated by members of the covenant committee. Receives unbonding transactions and returns the same transactions signed by the covenant emulator's key.
- **Bitcoin Full Node**: Verify whether the staking transaction has already been submitted to Bitcoin network and has the required amount of BTC confirmations.
- **Bitcoin Offline Wallet**: Stores the Covenant Signer member keys and signs unbonding transactions forwarded by the Covenant Signer. Covenant signer needs to operate a Bitcoin wallet, and connect to a Bitcoin node. For a detailed setup guide, visit Covenant Signer Setup Deployment
- **Global Configuration file**: Contains system-wide parameters pertinent to the processed Staking transactions.

## Deployment Order

### New Deployment

| Step                           | Tasks                                                                                                                                                            |
|--------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Core Nodes Setup**           | Bitcoin Full Node, Babylon Node                                                                                                                 |
| **Infrastructure Components**  | MongoDB Clusters: Indexer Database, API Database; RabbitMQ Message Queue System                                                                                  |
| **Database Migration (Optional)** | Clone Phase-1 database snapshot, apply snapshot to new MongoDB clusters. <br>*Required only if supporting Phase-1 registration data*                              |
| **Services Deployment**   | BTC Staking Indexer, Staking Expiry Checker, Staking API Service                                                                                                  |

### Upgrade from Existing Deployment

| Step                         | Tasks                                                                                                                                                  |
|------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Core Nodes Verification**  | Verify Bitcoin Full Node, Verify Babylon Node                                                                                                          |
| **Infrastructure Update**    | Update MongoDB Clusters, Update RabbitMQ configuration                                                                                                 |
| **Service Transition**       | Gracefully shutdown legacy indexer, Deploy new BTC Staking Indexer, Deploy Staking Expiry Checker, Deploy Staking API Service                           |