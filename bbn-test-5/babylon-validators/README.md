# Babylon Validator Setup

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Install Babylon Binary](#install-babylon-binary)
3. [Setup Node Home Directory and Configure](#setup-your-node-home-directory-and-configure)
4. [Setup Required Keys](#setup-the-required-keys-for-operating-a-validator)
5. [Sync Node](#sync-node)
6. [Get Funds](#get-funds)
7. [Create Validator](#create-validator)

## System Requirements

The Babylon node is built using the Cosmos SDK and has similar system requirements with typical Cosmos SDK ecosystem nodes.

As a reference, the following system specification is typically used by validators and found to be comfortable for high up-time operations.

- Quad Core or larger AMD or Intel (amd64) CPU
- 32GB RAM
- 1TB NVMe Storage
- 100MBps bidirectional internet connection

Note: the above is a sample system specification that might not fit your specific infrastructure. Please do your own research before committing to a
setup and verifying that it can scale well depending on your operations and needs.

## Install Babylon Binary 
<!-- TODO: check add in the correct tag for the testnet -->
Download [Golang 1.21](https://go.dev/dl) 

Using the go version 1.21.x (where x is any patch version like 1.21.0, 1.21.1, etc.)
Once installed run: 

```shell
go version
```

To ensure you are using the correct version, the terminal should return something similar to the below.

```shell
go: downloading go1.21 (darwin/arm64)
```

Subsequently clone the babylon [repository](https://github.com/babylonlabs-io/babylon).

```shell
git clone git@github.com:babylonlabs-io/babylon.git
```

Once the `babylon` repository is downloaded then checkout the corresponding tag for `bbn-testnet-5`.

``` shell
git checkout <tag>
```

You should now have the repository on your machine. Next navigate into the repository you just cloned and run the following:

```shell
make install
```

This command does the following:
- Builds the daemon
- Compile all Go packages in the project
- Installs the binary 
- Makes the `babylond` command globally accessible from your terminal

And should return something such as below:

```shell
go install -mod=readonly -tags "netgo ledger mainnet" -ldflags '-X github.com/cosmos/cosmos-sdk/version.Name=babylon -X github.com/cosmos/cosmos-sdk/version.AppName=babylond -X github.com/cosmos/cosmos-sdk/version.Version=v0.13.0 -X github.com/cosmos/cosmos-sdk/version.Commit=976e94b926dcf287cb487e8f35dbf400c7d930cc -X "github.com/cosmos/cosmos-sdk/version.BuildTags=netgo,ledger" -w -s' -trimpath  ./...
```

Now it has successfully compiled, lets check the available actions.

```shell
babylond
```

Which will give us a list of available actions.

```shell
Available Commands:
  add-genesis-account Add a genesis account to genesis.json
  collect-gentxs      Collect genesis txs and output a genesis.json file
  comet               CometBFT subcommands
  config              Utilities for managing application configuration
  ...
```

If this isn't working then it might not have saved successfully in your `gopath`

If it hasn't saved successfully in your gopath then it might have saved in the `./build` directory, so instead use the following from the project root directory.

```shell
./build/babylond
```
## Setup your node, home directory and configure 

Next we initialize the node and home directory. It should generate all of the necessary files such as `app.toml`, `client.toml`, `genesis.json` with the below command.

```shell
babylond init <moniker> --chain-id bbn-test-5 --home=./nodeDir
```

The `<moniker>` is a unique identifier for your node. So for example `node0`.

  Next we should navigate to `app.toml`, update the following section:

```shell
Base configuration
iavl-cache-size = 0

[btc-config]

# Configures which bitcoin network should be used for checkpointing
# valid values are: [mainnet, testnet, simnet, signet, regtest]
network = "signet"
```

In `app.toml` under `[btc-network]`change network to `signet` and `iavl-cache-size = 0` instead of what is listed in the automatically generated template.

Navigate to `config.toml`. Add in your seed that should look something like this `8fa2d1ab10dfd99a51703ba760f0ef555ae88f36@16.162.207.201:26656`

```shell
 P2P Configuration Options    

# Comma separated list of seed nodes to connect to
seeds = "8fa2d1ab10dfd99a51703ba760f0ef555ae88f36@16.162.207.201:26656"

# Comma separated list of nodes to keep persistent connections to
persistent_peers = "8fa2d1ab10dfd99a51703ba760f0ef555ae88f36@16.162.207.201:26656"
```

In the `config.toml` add in the `seeds` and `persistent-peers` token (this can be the same token).

We next want to add in the `genesis.json` file. To do this, either copy the genesis file from `https://rpc.devnet.babylonlabs.io/genesis` or we can use the terminal with the following command.

```
wget https://github.com/babylonlabs-io/networks/raw/main/bbn-test-5/genesis.tar.bz2
tar -xjf genesis.tar.bz2 && rm genesis.tar.bz2
mv genesis.json ~/.babylond/config/genesis.json
```

This file needs to overwrite the existing genesis file in the `~/.babylond/config/genesis.json` and please ensure that the `chain-id` is correct. The chain id is what you used in the `babylond init` command above.
## Setup the required keys for operating a validator 

### Keys for a CometBFT validator

Setting up the key is crucial as it serves as the validator's identity. The key-pair will be used for signing blocks, participating in consensus and managing validator operations. To add a key run the following command:

```shell
babylond --keyring-backend test keys add <name> --home=./nodeDir
```
  
We use `--keyring-backend test`, which specifies which backend to use for the keyring, `test` stores keys unencrypted on disk. The `<name>` specifies a unique identifier for the key.

The execution result displays the address of the newly generated key and its public key. Following is a sample output for the command:

```shell
- address: bbn1kvajzzn6gtfn2x6ujfvd6q54etzxnqg7pkylk9

name: test-val

pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"Ayau+8f945c1iQp9tfTVaCT5lzhD8n4MRkZNqpoL6Tpo"}'

type: local
```
### Keys for a BLS Voting
#### What is BLS Voting

BLS (Boneh-Lynn-Shacham) voting is used to create compact checkpoints at the end of each epoch. An epoch is a fixed period within the blockchain, defined or set by a number of blocks, during which a validator set remains consistent. This stability allows Babylon to create and submit checkpoints only once per epoch, reducing the overhead of interacting with the Bitcoin blockchain.

To read more on BLS Voting please see [here](#)
#### Create BLS Key

Validators are expected to submit a BLS signature at the end of each epoch. To do that, a validator needs to have a BLS key pair to sign information with.

Using your address from the keyring generation run:

```shell
babylond create-bls-key <address>
```

Your address should be the one that was generated in the keyring generation step and looks something like this: `bbn1kvajzzn6gtfn2x6ujfvd6q54etzxnqg7pkylk9`.

This command will create a BLS key and add it to the `~/.babylond/config/priv_validator_key.json` that was generated when `init` was run.

## Sync Node

We are now ready to sync the node.

```shell
babylond start --chain-id=bbn-test-5 --home=./nodeDir --minimum-gas-prices=0.005ubbn
```

Lets go through the flags of the above command:

- `start`: This is the command to start the Babylon node.
- `--chain-id bbn-test-5`: Specifies the ID of the blockchain network you're connecting to.
- `--home=./nodeDir`: Sets the directory for the node's data and configuration files and is dependant on where the files were generated for you from the initialization. In this case, it's using a directory named "nodeDir" in the current path.
- `--minimum-gas-prices=0.005ubbn`: This flag sets the minimum gas price for transactions the node will accept. This can also be manually set in the `app.toml`
#### Connect to Nodes

To connect your node to the network, you'll need peer addresses.
<!-- insert links when we have them -->

As mentioned in the configuration step, add these to your `config.toml` under `persistent_peers` or `seeds`.
#### Use a Snapshot

For faster syncing, you can use a snapshot instead of syncing from genesis. Snapshots are 
periodic backups of the chain state. Find them at:
<!-- - add link here -->

Note: Always verify snapshot sources and checksums before using them to ensure security.

## Get Funds
<!-- This needs to be updated to the correct testnet and potentially need help with the correct instructions as I cant access the faucet -->

Request Funds from the Babylon Testnet Faucet​ [here](https://faucet.devnet.babylonlabs.io/)

## Create Validator

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

```
bbnvaloper12k7w0mtdqp5yff8hr9gj6xe3uq7hnfhguqyqjg`
```
### Verify your Validator

To verify your validator, run:

```
babylond keys show <address or name> -a --bech val
```

Should return your validator address `bbnvaloper12k7w0mtdqp5yff8hr9gj6xe3uq7hnfhguqyqjg` which was returned during the `create-validator` action.

Next, lets check what is listed under the staking validator. Here we use the validator address we received in the response in the last command.

Here we run:

```
babylond query staking validator <validator address>
```

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

After the epoch (a period of time in which the chain divides time into different periods to help coordinate a number of network-wide activities) ends and if you have enough stake to be an active validator, performing this query will return you a status `BOND_STATUS_BONDED`. 

Congrats! You are now a validator on the Babylon system.

If you want to `delegate`, `redelegate`, `unbond` or `cancel-unbond`, please use the wrapped messages in the checkpointing and epoching modules as the messages in staking module are disabled. Read more [here](https://docs.babylonlabs.io/docs/developer-guides/modules/epoching#delaying-wrapped-messages-to-the-end-of-epochs)
