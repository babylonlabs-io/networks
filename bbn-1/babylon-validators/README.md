# Babylon Validator Setup

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [System Requirements](#2-system-requirements)
3. [Key Management](#3-key-management) 
   1. [Key for CometBFT consensus](#31-key-for-babylon-validators)
   2. [Babylon validator account keyring](#32-babylon-validator-account-keyring)
4. [CometBFT Validator Configuration](#4-cometbft-validator-configuration)
5. [Creating a Validator](#5-creating-a-validator)
   1. [Verifying Validator Setup](#51-verifying-validator-setup)
   2. [Understanding Validator Status](#52-understanding-validator-status)
   3. [Staking with your Validator](#53-staking-with-your-validator)
6. [Advanced Security Architecture](#6-advanced-security-architecture)
7. [Conclusion](#7-conclusion)

## 1. Prerequisites

Before setting up a validator, you'll need a fully synced Babylon node. For 
node setup instructions, see our [Node Setup Guide](../babylon-node/README.md).

## 2. System Requirements

Recommended specifications for running a Babylon validator node:
- CPU: Quad Core AMD/Intel (amd64)
- RAM: 32GB
- Storage: 2TB NVMe
- Network: 100MBps bidirectional
- Encrypted storage for keys and sensitive data
- Regular system backups (hourly, daily, weekly)

These are reference specifications for a production validator. 
Requirements may vary based on network activity and your operational needs.

## 3. Key Management

### 3.1 Keys for Babylon validators

When you initialize your node using `babylond init` (part of the node setup),
two types of keys are generated automatically. One is a CometBFT consensus key
pair, which is stored in `priv_validator_key.json`. This key is used by your
validator to participate in block creation and signing during the
consensus process at the CometBFT layer.
The other is BLS key pair, which is stored in `bls_key.json` along with
`bls_password.txt` following [EIP-2335](https://eips.ethereum.org/EIPS/eip-2335).
The key file location for both types of keys
is specified in your node's `config.toml` file.

Babylon validators are required to participate in
[BLS](https://en.wikipedia.org/wiki/BLS_digital_signature) voting
at the end of each epoch.
The Babylon blockchain defines epochs as a fixed number of blocks,
during which the validator set remains consistent.
At the end of the epoch,
the validator BLS signatures are aggregated to create a compact checkpoint
that is timestamped on the Bitcoin ledger.
The BLS voting mechanism achieves a significant reduction in the cost of
checkpoints, while the epoching mechanism specifies a defined frequency
for checkpointing in the Bitcoin blockchain.

> **🔒 Security Tip**: Make sure to securely store these key files. Losing
  either of them would mean losing control of your validator.

### 3.2 Babylon validator account keyring

The validator key is a fundamental component of your validator's identity 
within the Babylon network. This cryptographic key-pair serves multiple critical 
functions: it signs blocks during the consensus process, validates transactions, 
and manages your validator's operations on the network. Creating and securing 
this key is one of the most important steps in setting up your validator.

> **⚡ Note**: This key represents your validator's application layer account 
> and is different from the CometBFT Key for consensus. While the CometBFT key 
> is used for consensus-level operations, this key will be for the application-level
> operations such as managing your validator and withdrawing rewards.

We will be using [Cosmos SDK](https://docs.cosmos.network/v0.50/user/run-node/keyring) 
backends for key storage, which offer support for the following 
keyrings:

- `test` is a password-less keyring and is unencrypted on disk.
- `os` uses the system's secure keyring and will prompt for a passphrase at 
  startup.
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

#### 3.2.1 Get Funds

Before creating a validator, you will need sufficient BABY tokens in order 
to interact with the Babylon network and run a validator. 

## 4. CometBFT Validator Configuration

In this section, we are going to create a configuration file
that specifies the properties of your validator.

First, retrieve your validator's consensus public key using the following:

```shell
babylond tendermint show-validator --home <home>
```

This command reads your validator's key information from 
`priv_validator_key.json` and outputs only the public key in a specific format 
required for validator registration. The output will look like:

```shell
{"@type":"/cosmos.crypto.ed25519.PubKey","key":"0Wlt7ZPl0uvv7onsw4gP8FSQJUk986zMcOdWselDPM4="}
```

You'll need this formatted public key output to create your validator's 
configuration file in the next step.

Now we can use the output of the command above and replace the `pubkey` and
`<home>` value in the example below. Subsequently run the following command to 
create the validator configuration file:

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
create a `validator.json` file manually and then paste the above json into it 
but remember to replace all values with the actual values you want to use.

## 5. Creating a Validator

> ⚠️ **Important**: Please make sure to read through this section
> as it might not work with your automations for creating validators.

Unlike traditional Cosmos SDK chains that use the `staking` module, 
Babylon uses the Babylon
[`checkpointing`](https://docs.babylonlabs.io/guides/architecture/babylon_genesis_modules/checkpointing/)
module for validator creation and management.

Before proceeding, ensure that your
`<path>/config/priv_validator_key.json` file contains both your CometBFT 
consensus and BLS key pair as they are both required for the 
validator creation process. Recall that `<path>` is the `--home` directory 
you specified when setting up your node.

> ⚠️ **Warning**: When troubleshooting your validator, do not use `unsafe-reset-all` 
> unless you have backed up `priv_validator_key.json` and have a secure backup 
> plan in place. Running `unsafe-reset-all` will result in the removal of the BLS 
> keys within the `priv_validator_key.json` file.

> ⚠️ **Important**: You will need a funded account for this step.

To create your validator, run the following command:

```shell 
babylond tx checkpointing create-validator \
    ./<home-path>/config/validator.json \
    --chain-id bbn-1 \
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
- `--from`: The name of your validator key in the keyring
- `--keyring-backend`: The keyring backend type in which the above validator 
  key is stored
- `--home`: Specifies the directory where your node files will be stored. 

> **⚡ Note**: Make sure the account specified by `--from` has enough tokens to 
> cover both the stake amount and transaction fees. This is the same account 
> you created and funded earlier in 
> [Section 3](#32-babylon-validator-account-keyring).

Upon successful creation, you'll be asked to approve the transaction.
Within the transaction result output, you will find your validator's 
operator address (e.g., `bbnvaloper1qh8444k43spt6m8ernm8phxr332k85teavxmuq`).

After your validator creation transaction has been successfully submitted,
the Babylon blockchain will register your validator, but it will not activate
it until the end of the epoch. This is due to Babylon's epoched validator
set rotation mechanism, in which validator set and stake updates can
only happen at the end of each epoch. Each epoch lasts for about
60 minutes in the current mainnet.

> **⚡ Note**: You will not be able to query your validator details until
> the start of the next epoch. You can verify that your creation
> transaction has been registered by verifying the inclusion
> of its transaction hash in the blockchain.

### 5.1 Verifying Validator Setup

To verify your validator setup, you can use the following steps:

First, get your validator's operator address using your Babylon address: 

```shell
babylond keys show <your-key-name> --address --bech val --home <path> --keyring-backend <keyring-backend>
```

For example, for the address we used above is `bbn1qh8444k43spt6m8ernm8phxr332k85teavxmuq`, 
the operator address is `bbnvaloper1qh8444k43spt6m8ernm8phxr332k85teavxmuq`. 

For the next step, we will query your validator's details; however, results 
will not appear until the current epoch concludes (epochs last for 60 minutes).
This delay is due to the network's epoching mechanism, as mentioned earlier.

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

### 5.3 Staking with your Validator

> ⚠️ **Important**: Babylon uses the 
> [`checkpointing`](https://docs.babylonlabs.io/guides/architecture/babylon_genesis_modules/checkpointing/)
> module for validator creation and management.
> All staking-related transactions (delegate, redelegate, unbond) must be 
> processed through the `x/epoching` module, which encapsulates the `x/staking` 
> commands. These transactions will only take effect at the end of the epoch.

For staking operations, please use the commands below:

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

Each validator's needs are significantly varied based on their operational needs 
and the environment they are running in. Before setting up your validator 
infrastructure, take time to research different security architectures, including 
the [Sentry Node Architecture](https://hub.cosmos.network/main/validators/security#sentry-nodes-ddos-protection). 
This setup involves using intermediary nodes to protect your validator from 
direct exposure to the public network.

Additionally, the handling of the `priv_validator_key.json` file is critical. 
This file contains sensitive private key material vital for your validator's 
operation. If lost or compromised, it could lead to severe consequences 
including slashing penalties. Store this file securely using encrypted storage 
and maintain robust backup procedures.

## 7. Conclusion

Congratulations! Your validator is now part of the Babylon network. Remember to
monitor your validator's performance and maintain good uptime to avoid
penalties.
