# Deployment Overview for Bitcoin Staking Backend

This guide outlines the deployment process for the Bitcoin Staking Backend system. Follow the steps in sequence for successful installation or upgrade.

## Prerequisites

Before deploying the staking services, ensure the following components are properly set up:

- [ ] **Bitcoin Full Node** - [Setup Guide]()  
  _Powers transaction verification on the Bitcoin network_

- [ ] **Babylon Node** - [Setup Guide](../../../babylon-node/README.md)  
  _Connects to the Babylon blockchain for monitoring staking events_

- [ ] **MongoDB Clusters** - [Setup Guide]()  
  _Stores all staking data and transaction history_

- [ ] **RabbitMQ** - [Setup Guide]()  
  _Handles message queuing between system components_

- [ ] **Global Configuration** - [Setup Guide](../services/global-config.md)  
  _Defines system-wide parameters for all services_

<!-- - [ ] **Database Migration (Optional)** - Clone Phase-1 database snapshot, apply snapshot to new MongoDB clusters.  
  _Required only if supporting Phase-1 registration data_ -->

> **Note:** If upgrading an existing deployment, ensure you gracefully shut down any legacy indexer services before proceeding.

## Launching Services

Once all prerequisites are checked off, deploy these services in the following order:

### 1. Deploy Staking Indexer
- [Staking Indexer Setup Guide](../services/staking-indexer.md)
- _This service monitors both blockchains and processes all staking events_

### 2. Deploy Staking Expiry Checker
- [Staking Expiry Checker Setup Guide](../services/staking-expiry-checker.md)
- _Manages expired delegations and state transitions_

### 3. Deploy Staking API Service
- [Staking API Service Setup Guide](../services/staking-api-service.md)
- _Provides the API endpoints for all staking operations_
- ✓ Test the API endpoints after deployment

## Verification

After completing all steps, verify your deployment by:
1. Checking service logs for any errors
2. Using the `/healthcheck` endpoint to verify API service health
