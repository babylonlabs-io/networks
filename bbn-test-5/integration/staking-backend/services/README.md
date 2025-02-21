## Services

The Bitcoin Staking Backend consists of three core services that work together to enable secure and efficient staking operations. These services handle everything from monitoring the Bitcoin blockchain for staking transactions to managing delegation lifecycles and providing API access.

### Prerequisites
#### Golang
BTC staking backend services requires Golang [version 1.23.1](https://go.dev/doc/install) or later to be installed on your system. Install it using the instructions on the provided link.

### Components

### 1. [BTC Staking Indexer](./staking-indexer.md)
- Monitors Bitcoin blockchain
- Parses staking-related transactions
- Forwards events to RabbitMQ
- Maintains persistent transaction record

### 2. [Staking API Service](./staking-api-service.md)
- Processes staking transactions
- Handles unbonding requests
- Manages central data store
- Provides REST API endpoints

### 3. [Staking Expiry Checker](./staking-expiry-checker.md)
- Monitors delegation status
- Processes expired stakes
- Triggers unbonding workflows
- Maintains system integrity