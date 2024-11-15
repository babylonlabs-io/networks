# Babylon Node Setup

## Table of Contents

1. [Install Babylon Binary](#install-babylon-binary)
2. [Setup Node Home Directory and Configure](#setup-your-node-home-directory-and-configure)
4. [Setup Required Keys](#setup-the-required-keys-for-operating-a-validator)
5. [Sync Node](#sync-node)
6. [Get Funds](#get-funds)


## Install Babylon Binary 

1. Install [Golang 1.21+](https://go.dev/dl)
2. Verify installation:

```shell
go version
```

3. Clone and build Babylon:
```shell
git clone git@github.com:babylonlabs-io/babylon.git
cd babylon
git checkout bbn-test-5  # TODO: testnet tag to be defined
make install
```
This command does the following:
- Builds the daemon
- Compiles all the Go packages in the project
- Installs the binary 
- Makes the `babylond` command globally accessible from your terminal

You should expect to see the following output:

```shell
# Build output will show:
go install -mod=readonly -tags "netgo ledger mainnet" \
    -ldflags '\
        -X github.com/cosmos/cosmos-sdk/version.Name=babylon \
        -X github.com/cosmos/cosmos-sdk/version.AppName=babylond \
        -X github.com/cosmos/cosmos-sdk/version.Version=v0.13.0 \
        -X github.com/cosmos/cosmos-sdk/version.
        Commit=976e94b926dcf287cb487e8f35dbf400c7d930cc \
        -X "github.com/cosmos/cosmos-sdk/version.BuildTags=netgo,ledger" \
        -w -s' \
    -trimpath ./...
```

Now it has successfully compiled, lets check the available actions
through the `babylond` command:

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

If the babylond command isn't found, ensure `$GOPATH/bin` is in your shell's 
`$PATH`. Add it with:

 ```shell 
 export PATH=$HOME/go/bin:$PATHecho 'export PATH=$HOME/go/bin:$PATH' >>
 ~/.profile 
 ```

## Setup your node, home directory and configure 

Initialize your node and create the necessary configuration directory. 
This command will generate several important configuration files 
including `app.toml`, `client.toml`, and `genesis.json`:

```shell
babylond init <moniker> --chain-id bbn-test-5 --home <path>
```

The `<moniker>` is a unique identifier for your node. So for example `node0`.
The `<path>` is the directory where the node files will be stored 
(e.g. `--home ./nodeDir`).

After initialization, you'll need to modify two important configuration files:

1. First, open `app.toml` and update these essential settings:

```shell
Base configuration
minimum-gas-prices = "0.005ubbn"
iavl-cache-size = 0
iavl-disable-fastnode=true

[btc-config]

# Configures which bitcoin network should be used for checkpointing
# valid values are: [mainnet, testnet, simnet, signet, regtest]
network = "signet" # Bitcoin network for checkpointing
```

In `app.toml` under `[btc-network]`change network to `signet` and under 
`Base Configuration` set `iavl-cache-size = 0` and `iavl-disable-fastnode=true` 
instead of what is listed in the automatically generated template. 
Additionally, add `minimum-gas-prices = "0.005ubbn"`

Navigate to `config.toml`. Add in your seed that should look something like 
this `8fa2d1ab10dfd99a51703ba760f0ef555ae88f36@16.162.207.201:26656`

```shell
 P2P Configuration Options    

# Comma separated list of seed nodes to connect to
seeds = "8fa2d1ab10dfd99a51703ba760f0ef555ae88f36@16.162.207.201:26656"
```

Next, you'll need to obtain the network's genesis file. This file contains 
the initial state of the blockchain and is crucial for starting from the 
correct point. You have two options:

1. Download directly from the RPC endpoint: `https://rpc.devnet.babylonlabs.io/genesis`

2. Or use these commands in your terminal:

```
wget https://github.com/babylonlabs-io/networks/raw/main/bbn-test-5/genesis.tar.bz2 # update this file name if necessary
tar -xjf genesis.tar.bz2 && rm genesis.tar.bz2
mv genesis.json ~/.babylond/config/genesis.json
```

>Note: Verify that the `chain-id` in the genesis file matches the one used in 
your initialization command (`bbn-test-5`). This ensures your node connects 
to the correct network.

## Setup the required keys for operating a validator 

### Keys for a CometBFT validator

The validator key is a fundamental component of your validator's identity 
within the Babylon network. This cryptographic key-pair serves multiple critical 
functions: it signs blocks during the consensus process, validates transactions, 
and manages your validator's operations on the network. Creating and securing this 
key is one of the most important steps in setting up your validator.

To generate your validator key, use the following command:

```shell
babylond --keyring-backend test keys add <name> --home <path>
```
We use `--keyring-backend test`, which specifies which backend to use for the 
keyring, `test` stores keys unencrypted on disk. 

There are three options for the keyring backend:

`test`: Stores keys unencrypted on disk. It’s meant for testing purposes and 
should never be used in production.
`file`: Stores encrypted keys on disk, which is a more secure option than test but 
less secure than using the OS keyring.
`os`: Uses the operating system's native keyring, providing the highest level of 
security by relying on OS-managed encryption and access controls.

The `<name>` specifies a unique identifier for the key.

The execution result displays the address of the newly generated key and its 
public key. Following is a sample output for the command:

```shell
- address: bbn1kvajzzn6gtfn2x6ujfvd6q54etzxnqg7pkylk9
name: <name>
pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey",
key: "Ayau+8f945c1iQp9tfTVaCT5lzhD8n4MRkZNqpoL6Tpo"}'
type: local
```

Make sure to securely store this information, particularly your address and 
private key details. Losing access to these credentials would mean losing 
control of your validator and any staked funds.

### Keys for a BLS Voting
#### What is BLS Voting

BLS (Boneh-Lynn-Shacham) voting is used to create compact checkpoints at the 
end of each epoch. An epoch is a fixed period within the blockchain, defined or 
set by a number of blocks, during which a validator set remains consistent. 
This stability allows Babylon to create and submit checkpoints only once per 
epoch, reducing the overhead of interacting with the Bitcoin blockchain.

To read more on BLS Voting please see [here](#) # TODO: add link when it is ready 

#### Create BLS Key

The Babylon network uses BLS (Boneh-Lynn-Shacham) signatures as an efficient 
way to create consensus checkpoints at the conclusion of each epoch. As a validator, 
you'll need to participate in this process by submitting BLS signatures. 
This requires a special BLS key pair that's separate from your validator key.

To generate your BLS key, you'll use your validator address from the previous step. 
Run this command:

```shell
babylond create-bls-key <address>
```

Replace `<address>` with your validator address from the earlier keyring 
generation (it should look similar to `bbn1kvajzzn6gtfn2x6ujfvd6q54etzxnqg7pkylk9`). 

The system will automatically:
1. Generate a new BLS key pair
2. Associate it with your validator address
3. Store it in your node's configuration file at 
`~/.<path>/config/priv_validator_key.json`

This key will be used automatically by your validator software when it needs 
to participate in epoch-end signature collection. The BLS signatures help 
create compact, efficient proofs of consensus that can be verified by other 
blockchain networks, particularly Bitcoin.

Important: The `priv_validator_key.json` file contains sensitive key material. 
Make sure to backup this file and store it securely, as it's essential for your 
validator's operation and cannot be recovered if lost.

## Sync Node

We are now ready to sync the node.

```shell
babylond start --chain-id bbn-test-5 --home <path> --x-crisis-skip-assert-invariants
```

Lets go through the flags of the above command:

- `start`: This is the command to start the Babylon node.
- `--chain-id`: Specifies the ID of the blockchain network you're connecting to.
- `--home`: Sets the directory for the node's data and configuration files and 
is dependant on where the files were generated for you from the initialization. 
In this case, it's using a directory named "nodeDir" in the current path.
- `--minimum-gas-prices`: This flag sets the minimum gas price for transactions 
the node will accept. This can also be manually set in the `app.toml`

#### Connect to Nodes

To connect your node to the network, you'll need peer addresses.
<!-- insert links when we have them -->

As mentioned in the configuration step, add these to your `config.toml` 
under `persistent_peers` or `seeds`.

#### Use a Snapshot

For faster syncing, you can use a snapshot instead of syncing from genesis. 
Snapshots are periodic backups of the chain state. Find them at:
<!-- - add link here -->

Note: Always verify snapshot sources and checksums before using them to ensure security.

## Get Funds

To create a validator, you'll need some BBN tokens to:
1. Pay for transaction fees (gas)
2. Meet the minimum self-delegation requirement
3. Stake as your initial validator bond

You can obtain testnet tokens through two methods:

1. Request funds from the Babylon Testnet Faucet 
[here](https://faucet.devnet.babylonlabs.io/)

2. Join our Discord server and visit the #faucet channel: 
[Discord Server](https://discord.com/channels/1046686458070700112/1075371070493831259)

Note: These are testnet tokens with no real value, used only for testing 
and development purposes. The tokens help you experiment with validator 
operations without risking real assets.

## Next Steps

For information about becoming a Finality Provider in the Babylon network, 
see our [Finality Provider Guide](../babylon-validators/README.md).