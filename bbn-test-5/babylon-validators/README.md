# Babylon Validator Setup

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup](#setup) \
   2.1. [Setup Node and Configure](#setup-node-and-configure) \
   2.2. [Build node from `x` tag](#build-node-from-x-tag) \
   2.3. [Initialize the chain](#initialize-the-chain) \
   2.4. [Update the configuration](#update-the-configuration) \
   2.5. [Retrieve the genesis file](#retrieve-the-genesis-file) \
   2.6. [Create a Keyring](#create-a-keyring) \
   2.7. [Get Funds](#get-funds) \
   2.8. [What is BLS Voting](#what-is-bls-voting) \
   2.9. [Create BLS Key](#create-bls-key)
3. [Run Node](#run-node)
4. [Create Validator](#create-validator)
5. [Verify your Validator](#verify-your-validator)

## Prerequisites

This system spec has been tested by validators and found to be comfortable:

- Quad Core or larger AMD or Intel (amd64) CPU
- 32GB RAM
- 1TB NVMe Storage
- 100MBps bidirectional internet connection

You can run Babylon on lower-spec hardware for each component, but you may find that it is not highly performant or prone to crashing.
## Setup

We need to setup the following before we can classify as a validator. 
- Setup node and configure
- Create keyring
- Get funds
- Create BLS Key
- Run node

### Setup Node and Configure

<!-- TODO: check add in the correct tag for the testnet -->
#### Build node from `x` tag. 

Here we will checkout the tag in which we will use. 

` git checkout x`

#### Initialize the chain

Run  `babylond init --chain-id bbn-test-5` in the terminal 

It should generate all of the necessary files such as `app.toml`, `client.toml`, `genesis.json`

#### Update the configuration

We need to then change the configuration details in the following files. 
- In `app.toml` under `[btc-network]`change network to `signet` and `iavl-cache-size = 0`
- In the `config.toml` add in the `seeds` and `persistent-peers` token (this can be the same token)

#### Retrieve the genesis file 

We next want to add in the genesis file from thee network. How we can do this is either copy the genesis file from  `https://rpc.devnet.babylonlabs.io/genesis` or we can use the terminal.

```
wget https://github.com/babylonlabs-io/networks/raw/main/bbn-test-5/genesis.tar.bz2  
tar -xjf genesis.tar.bz2 && rm genesis.tar.bz2  
mv genesis.json ~/.babylond/config/genesis.json
```

This file needs to overwrite the existing genesis file in the `~/.babylond/config/genesis.json` and please ensure that the `chain-id` is correct.

#### Create a Keyring

What we want to do next is create a key we can do this by running:

`babylond --keyring-backend test keys add <name>`

We use `--keyring-backend test`, which specifies which backend to use for the keyring, `test` stores keys unencrypted on disk. At the end we add a `name` which is the name in which we will give to the key. 

What should return is a message that the key was added successfully. An example of what this should look like is below:

```
- address: bbn1kvajzzn6gtfn2x6ujfvd6q54etzxnqg7pkylk9
  name: test-val
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"Ayau+8f945c1iQp9tfTVaCT5lzhD8n4MRkZNqpoL6Tpo"}'
  type: local
```

#### Get Funds
<!-- This needs to be updated to the correct testnet and potentially need help with the correct instructions as I cant access the faucet -->
Request Funds from the Babylon Testnet Faucet​ [here](https://faucet.devnet.babylonlabs.io/) 

##### What is BLS Voting

 BLS (Boneh-Lynn-Shacham) voting is used to create compact checkpoints at the end of each epoch. An epoch is a fixed period within the blockchain, defined or set by a number of blocks, during which a validator set remains consistent. This stability allows Babylon to create and submit checkpoints only once per epoch, reducing the overhead of interacting with the Bitcoin blockchain.

Once an epoch begins, the validator set is responsible for block creation and validators remain constant throughout that epoch. Each validator has BLS Keys in addition to their standard validator keys. At the end of each epoch validators cast their vote using their BLS keys and the BLS public key is registered on the Babylon network. The BLS public key is registered on the Babylon network. Valid BLS signatures are then collated into a single signature which is then used for a babylon checkpoint. A checkpoint is not only made up of aggregated BLS signatures from the validator set but also a hash of the last block in the epoch and other epoch related data. These checkpoints are submitted to the BTC blockchain. providing an immutable record of Babylon's state and protecting against long-range attacks.

The primary difference between BLS voting and regular voting is the signature aggregation. This allows Babylon to create very compact proofs of validator participation, which can be efficiently stored and verified on Bitcoin. This mechanism is crucial for Babylon's security model, enabling it to leverage Bitcoin's security while maintaining its own Proof-of-Stake system.

#### Create BLS Key

Validators are expected to submit a BLS signature at the end of each epoch. To do that, a validator needs to have a BLS key pair to sign information with.

Using your address from the keyring generation run:
`babylond create-bls-key <address>`

Your address should be the one that was generated in the keyring generation step and looks something like this: `bbn1kvajzzn6gtfn2x6ujfvd6q54etzxnqg7pkylk9`

This command will create a BLS key and add it to the `~/.babylond/config/priv_validator_key.json` that was generated when `init` was run.

### Run Node

We are now ready to run the node.

`./build/babylond start --chain-id=bbn-test-5 --home=./nodeDir --log_level=info --minimum-gas-prices=0.005ubbn`

Lets go through the flags of the above command:

- `start`: This is the command to start the Babylon node.
- `--chain-id bbn-test-5`: Specifies the ID of the blockchain network you're connecting to.
- `--home=./nodeDir`: Sets the directory for the node's data and configuration files and is dependant on where the files were generated for you from the initialization. In this case, it's using a directory named "nodeDir" in the current path.
- `--log_level=info`: This sets the logging verbosity to "info" level, which means you will see general operational logs, warnings and errors
- `--minimum-gas-prices=0.005ubbn`: This flag sets the minimum gas price for transactions the node will accept. This can also be manually set in the `app.toml`

### Create Validator

Contrary to a vanilla Cosmos SDK chain, a validator for Babylon is created through the `babylond tx checkpointing create-validator` command. This command expects that a BLS validator key exists under the `~/.babylond/config/priv_validator_key.json`.

To create the validator (using sample parameters):

```
babylond tx checkpointing create-validator ./dir/node0/babylond/config/priv_validator_key.json\
--chain-id="devnet-2" \  
--gas="auto" \  
--gas-adjustment="1.5" \  
--gas-prices="0.025ubbn" \  
--from=bbn12k7w0mtdqp5yff8hr9gj6xe3uq7hnfhgpzwa7f
```

This should return a transaction, which contains your validator address as below:
`bbnvaloper12k7w0mtdqp5yff8hr9gj6xe3uq7hnfhguqyqjg`

### Verify your Validator

To verify your validator, run:

`./build/babylond keys show <address or name> -a --bech val`

Should return your validator address `bbnvaloper12k7w0mtdqp5yff8hr9gj6xe3uq7hnfhguqyqjg` which was returned during the `create validator` action.

Next lets check what is listed under the staking validator. Here we use the validator address we received in the response in the last command.

Here we run:
`babylond query staking validator <validator address>`

And should receive a response that corresponds to the params from your`create-validator` transaction.

```
validator:
  commission:
    commission_rates:
      max_change_rate: "10000000000000000"
      max_rate: "1000000000000000000"
      rate: "100000000000000000"
    update_time: "2024-10-23T12:21:59.581302666Z"
  consensus_pubkey:
    type: tendermint/PubKeyEd25519
    value: jKjSVn02f8XbnJe4KWxwOWCGGmvyz++3g+8Ppfmbwfw=
  delegator_shares: "100000000000000000000"
  description:
    details: node0val
    moniker: node0
    security_contact: node0@gmail.com
    website: https://myweb.site
  min_self_delegation: "1"
  operator_address: bbnvaloper12k7w0mtdqp5yff8hr9gj6xe3uq7hnfhguqyqjg
  status: 1
  tokens: "100"
  unbonding_time: "1970-01-01T00:00:00Z"
```


After the epoch (a period of time in which the chain divides time into different periods to help coordinate a number of network-wide activities) ends and if you have enough stake to be an active validator, performing this query will return you a status `BOND_STATUS_BONDED`. Congrats! You are now a validator on the Babylon system.

If you want to delegate, redelegate, unbond or cancel-unbond, please use the wrapped messages in the checkpointing and epoching modules as the messages in staking module are disabled. Read more [here](https://docs.babylonlabs.io/docs/developer-guides/modules/epoching#delaying-wrapped-messages-to-the-end-of-epochs)

