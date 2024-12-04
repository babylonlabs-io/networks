# Babylon Validator Setup

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [System Requirements](#2-system-requirements)
3. [Key Management](#3-key-management) 
   1. [Keys for a CometBFT validator](#31-keys-for-a-cometbft-validator)
      1. [Get Funds](#311-get-funds)
   2. [BLS Voting Keys](#32-keys-for-a-bls-voting)
      1. [What is BLS Voting](#321-what-is-bls-voting)
      2. [Create BLS Key](#322-create-bls-key)
4. [Validator Configuration](#4-validator-configuration)
5. [Creating a Validator](#5-creating-a-validator)
   1. [Verifying Validator Setup](#51-verifying-validator-setup)
   2. [Understanding Validator Status](#52-understanding-validator-status)
   3. [Managing Your Validator](#53-managing-your-validator)
6. [Advanced Security Architecture](#6-advanced-security-architecture)
7. [Enhanced Monitoring](#7-enhanced-monitoring)
   1. [Prometheus Configuration](#71-prometheus-configuration)
   2. [Basic Health Checks](#72-basic-health-checks)

## 1. Prerequisites

Before setting up a validator, you'll need a fully synced Babylon node. For 
node setup instructions, see our [Node Setup Guide](../babylon-node/README.md).

## 2. System Requirements

Recommended specifications for running a Babylon validator node:
<!-- TODO: RPC Nodes more ram is required add when we have completed node load test  -->
- CPU: Quad Core AMD/Intel (amd64)
- RAM: 32GB
- Storage: 2TB NVMe
- Network: 100MBps bidirectional
- Encrypted storage for keys and sensitive data
- Regular system backups (hourly, daily, weekly)
- DDoS protection

These are reference specifications for a production validator. 
Requirements may vary based on network activity and your operational needs.

## 3. Key Management
### 3.1 Key for CometBFT consensus

The validator key is a fundamental component of your validator's identity 
within the Babylon network. This cryptographic key-pair serves multiple critical 
functions: it signs blocks during the consensus process, validates transactions, 
and manages your validator's operations on the network. Creating and securing this 
key is one of the most important steps in setting up your validator.

We will be using [Cosmos SDK](https://docs.cosmos.network/v0.50/user/run-node/keyring) 
backends for key storage, which offer support for the following 
keyrings:

- `test` is a password-less keyring and is unencrypted on disk.
- `os` uses the system's secure keyring and will prompt for a passphrase at startup.
- `file` encrypts the keyring with a passphrase and stores it on disk.

To generate your validator key, use the following command:

```shell
babylond keys add <name> --home <path> --keyring-backend <keyring-backend>
```

Parameters:
The `<name>` specifies a unique identifier for the key.
- `--home` specifies the directory where your node files will be stored 
  (e.g. `--home ./nodeDir`)
- `--keyring-backend` specifies the keyring backend to use, can be `test`, `file`, 
or `os`.

The execution result displays the address of the newly generated key and its 
public key. Following is a sample output for the command:

```shell
- address: bbn1kvajzzn6gtfn2x6ujfvd6q54etzxnqg7pkylk9
  name: <name>
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey",
           key: "Ayau+8f945c1iQp9tfTVaCT5lzhD8n4MRkZNqpoL6Tpo"}'
  type: local
```

> **🔒 Security Tip**: Make sure to securely store this information, particularly 
> your private key details. Losing access to the private key would 
> mean losing control of your validator.

Before creating a validator, you will need sufficient BBN tokens. For instructions 
on obtaining BBN tokens, see the [Get Funds section](../babylon-node/README.md#get-funds) 
in the Node Setup Guide.

#### 3.1.1 Get Funds

Funds are necessary to interact with the Babylon network and run a validator. 
To source funds you will need to request them from the Babylon Testnet Faucet.

<!-- TODO: add information or commands on how to request funds from the faucet -->

### 3.2  Key for BLS Voting
#### 3.2.1 What is BLS Voting

Babylon validators are required to participate in
[BLS](https://en.wikipedia.org/wiki/BLS_digital_signature) voting
at the end of each epoch.
The Babylon blockchain defines epochs as a fixed period
within the blockchain, defined by a number of blocks,
during which the validator set remains consistent. 
At the end of the epoch,
the validator BLS signatures are aggregated to create a compact checkpoint
that is timestamped on the Bitcoin ledger.
The BLS voting mechanism achieves a significant reduction in the cost of
checkpoints, while the epoching mechanism specifies a defined frequency
for checkpointing in the Bitcoin blockchain.

#### 3.2.2 Create BLS Key

To generate your BLS key, you'll need to use your validator address from the 
previous step. 

Run this command:

```shell
babylond create-bls-key <address> --home <path>
```

Replace `<address>` with your address from the earlier keyring 
generation (it should look similar to `bbn1kvajzzn6gtfn2x6ujfvd6q54etzxnqg7pkylk9`). 

The above command will:
1. Generate a new BLS key pair
2. Associate it with your validator address
3. Store it in your node's configuration file at 
`~/.<path>/config/priv_validator_key.json`

This key will be used automatically by your validator software when it needs 
to participate in epoch-end signature collection. The BLS signatures help 
create compact, efficient proofs of consensus that can be later timestamped to Bitcoin.

> ⚠️ **Important**: The `priv_validator_key.json` file contains sensitive key 
> material. Make sure to backup this file and store it securely, as it's 
> essential for your validator's operation and cannot be recovered if lost.
> Note that BLS keys are currently not supported by Horcrux or other remote signing 
> solutions, so additional security measures should be considered for key management.

## 4. CometBFT Validator Configuration

First, we need to get the validator's consensus public key to create the 
validator configuration file:

```shell
babylond tendermint show-validator --home <home>
```

It will output a public key in the following format:

```shell
{"@type":"/cosmos.crypto.ed25519.PubKey","key":"0Wlt7ZPl0uvv7onsw4gP8FSQJUk986zMcOdWselDPM4="}
```

Use the output of the command above and replace the `pubkey` and `<home>` 
value in the example below. 
Then subsequently run the following command to create the validator configuration file:

```shell
cat > <home>/config/validator.json << EOF
{
  "pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"0Wlt7ZPl0uvv7onsw4gP8FSQJUk986zMcOdWselDPM4="},
  "amount": "1000000ubbn",
  "moniker": "my-validator",
  "commission-rate": "0.10",
  "commission-max-rate": "0.20",
  "commission-max-change-rate": "0.01",
  "min-self-delegation": "1"
}
EOF
```

Parameters:
- `pubkey`: Your validator's public key (the output you received before)
- `amount`: Initial self-delegation amount
- `moniker`: Your validator's name/identifier
- `commission-rate`: Validator commission rate 
- `commission-max-rate`: Specifies the maximum you can raise your commission in the future.
- `commission-max-change-rate`: Maximum daily commission change rate
- `min-self-delegation`: Minimum amount you must keep self-delegated

If you prefer to add this manually or are having issues, another option is to 
create a `validator.json` file and then paste the above json into it but remember
to replace all values with the actual values you want to use.

## 5. Creating a Validator

> ⚠️ **Important**: You will need a funded account for this step

> ⚠️ **Important**: Please make sure to read through this section
> as it might not work with your automations for creating validators.

Unlike traditional Cosmos SDK chains that use the `staking` module, 
Babylon uses the [`checkpointing`](https://docs.babylonlabs.io/docs/developer-guides/modules/checkpointing) module for validator creation and management.

The creation process requires your previously generated BLS key and your validator 
key, which should be located at `<path>/config/validator.json`, 
where `<path>` is the `--home` directory you specified when setting up your node.

The BLS key in the file is required as validators use their BLS key to sign 
checkpoint messages, which are aggregated and submitted to Bitcoin for finality.

To create your validator, run the following command:

```shell 
babylond tx checkpointing create-validator \
    ./<home-path>/config/validator.json \
    --chain-id bbn-test-5 \
    --gas "auto" \
    --gas-adjustment 1.5 \
    --gas-prices "0.005ubbn" \
    --from <your-key-name> \
    --keyring-backend <keyring-backend> \
    --home <path>
```

Parameters:
- `--chain-id`: The network identifier
- `--gas`: Set to "auto" to automatically calculate the gas needed
- `--gas-adjustment`: A multiplier for the estimated gas 
- `--gas-prices`: Transaction fee in ubbn per unit of gas
- `--from`: Your key name or address that will sign and pay for this transaction
- `--keyring-backend`: Specifies the keyring backend to use for key management. 
  We have used `test` in our example.
- `--home`: Specifies the directory where your node files will be stored 

Upon successful creation, you'll be asked to approve the transaction. 
Once approved, you'll receive a transaction hash and your validator
operator address 
(e.g., `bbnvaloper1qh8444k43spt6m8ernm8phxr332k85teavxmuq`).

### 5.1 Verifying Validator Setup

To verify your validator setup, you can use the following steps:

First, get your validator's operator address using your Babylon address: 

```shell
babylond keys show <your-key-name> --address --bech val --home <path> --keyring-backend <keyring-backend>
```

For example, for the address we used above is `bbn1qh8444k43spt6m8ernm8phxr332k85teavxmuq`, 
the operator address is `bbnvaloper1qh8444k43spt6m8ernm8phxr332k85teavxmuq`. 

For the next step, we will have to wait till the beginning of the next epoch 
(this will take approx 10 minutes) for the command to be valid. This is due to 
Babylon's epoched staking design, where the blockchain is divided into epochs.
Messages that affect the validator set are delayed to the end of each epoch for 
execution. Meaning that your validator creation transaction will be processed 
at the end of the current epoch, and you won't be able to query your validator 
details until the next epoch begins. In the meantime, you can verify your 
transaction was successful by checking its hash.

```shell 
babylond query staking validator <validator-operator-address>
```

The output should return the selected validator's configuration.

```yaml 
validator:
  commission:
    rates:
      current: "100000000000000000" 
      max: "1000000000000000000" 
      max_change: "10000000000000000"
  description:
    moniker: "my-validator" 
    website: "https://myweb.site" 
    security_contact: "my-validator0@gmail.com"
  status: 1 
  tokens: "100"
```

Usually when first creating a validator, the immediate status will be 
`BOND_STATUS_UNBONDED`. To see your validator's status change you will need to 
wait for the epoch to end.

### 5.2 Understanding Validator Status

Your validator enters the active set based on two conditions: 
1. Having sufficient stake to qualify for the active set.
2. The completion of the epoch (a network-wide time period for 
coordinating activities) in which your validator qualified for the active set.

When active, your status will show as `BOND_STATUS_BONDED`.

The other status codes are:

```shell
BOND_STATUS_UNSPECIFIED = 0
BOND_STATUS_UNBONDED = 1
BOND_STATUS_UNBONDING = 2
BOND_STATUS_BONDED = 3
```

### 5.3 Managing Your Validator

> ⚠️ **Important**: Babylon uses the `epoching` module to wrap staking 
> operations. 
> All staking-related transactions (delegate, redelegate, unbond) must be 
> executed through the `x/epoching` module, the `x/epoching` module wraps the 
> commands of `x/staking` and all staking related transactions will take 
> into effect at the end of the epoch.

For validator operations, use the standard Cosmos SDK staking module commands:

```shell
# Delegate tokens to a validator
babylond tx epoching delegate [validator-addr] [amount] \
    --from <delegator-key> \
    --chain-id <chain-id>

# Redelegate tokens from one validator to another
babylond tx epoching redelegate [src-validator-addr] [dst-validator-addr] [amount] \
    --from <delegator-key> \
    --chain-id <chain-id>

# Unbond tokens from a validator
babylond tx epoching unbond [validator-addr] [amount] \
    --from <delegator-key> \
    --chain-id <chain-id>
```

For more information on the epoching module and wrapped messages, see the 
[Epoching Module](https://github.com/babylonlabs-io/babylon/blob/main/x/epoching/README.md?plain=1#L150-L155) 
documentation. 

## 6. Advanced Security Architecture

Each validator's needs significantly vary based on their operational needs and 
the environment they are running in. Before setting up your validator 
infrastructure, take time to research different security architectures, including 
the [Sentry Node Architecture](https://hub.cosmos.network/main/validators/security#sentry-nodes-ddos-protection). 
This setup involves using intermediary nodes to protect your validator from 
direct exposure to the public network.

Handling of the `priv_validator_key.json` file is critical. This file contains 
sensitive private key material vital for your validator's operation. 
If lost or compromised, it could lead to severe consequences including slashing 
penalties. Store this file securely using encrypted storage and maintain 
robust backup procedures.

## 7. Conclusion

Congratulations! Your validator is now part of the Babylon network. Remember to
monitor your validator's performance and maintain good uptime to avoid
penalties.
