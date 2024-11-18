# Babylon Node Setup

## Table of Contents

1. [Install Babylon Binary](#install-babylon-binary)
2. [Setup Node Home Directory and Configure](#setup-your-node-home-directory-and-configure)
4. [Setup Required Keys](#setup-the-required-keys-for-operating-a-validator)
5. [Sync Node](#sync-node)
6. [Get Funds](#get-funds)


## Install Babylon Binary 

1. Install [Golang 1.21](https://go.dev/dl)
2. Verify installation:

```shell
go version
```

3. Clone and build Babylon:
```shell
git clone git@github.com:babylonlabs-io/babylon.git
cd babylon
git checkout bbn-test-5  
make install
```
<!-- TODO: testnet tag to be defined -->
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

Now that the binary has been successfully installed, 
let's check the available actions through the `babylond` command:

```shell
babylond
Available Commands:
  add-genesis-account Add a genesis account to genesis.json
  collect-gentxs      Collect genesis txs and output a genesis.json file
  comet               CometBFT subcommands
  config              Utilities for managing application configuration
  ...
```

If the `babylond` command isn't found, ensure `$GOPATH/bin` is in your shell's 
`$PATH`. Add it with:

 ```shell 
 echo 'export PATH=$HOME/go/bin:$PATH' >> ~/.profile 
 ```

## Setup your node, home directory, and configuration

Initialize your node and create the necessary configuration directory. 
This command will generate several important configuration files 
including `app.toml`, `client.toml`, and `genesis.json`:

```shell
babylond init <moniker> --chain-id bbn-test-5 --home <path>
```

The `<moniker>` is a unique identifier for your node (e.g. `node0`).
The `<path>` is the home directory of the node in which the relevant node files will be stored 
(e.g. `--home ./nodeDir`).

After initialization, you'll need to modify two important configuration files:

1. First, open `app.toml` and update these essential settings from what is auto-generated:

```shell
# Base configuration
minimum-gas-prices = "0.005ubbn"
iavl-cache-size = 0
iavl-disable-fastnode=true

[btc-config]

# Configures which bitcoin network should be used for checkpointing
# valid values are: [mainnet, testnet, simnet, signet, regtest]
network = "signet" # The Babylon testnet connects to the signet Bitcoin network
```

Navigate to `config.toml`. Add in your seed, as shown below:

```shell
 #P2P Configuration Options    

# Comma separated list of seed nodes to connect to
seeds = "8fa2d1ab10dfd99a51703ba760f0ef555ae88f36@16.162.207.201:26656"
```

Next, you'll need to obtain the network's genesis file. This file contains 
the initial state of the blockchain and is crucial for successfully syncing 
your node. You can get it from:

1. The official Babylon Networks repository: [bbn-test-5](https://github.com/babylonlabs-io/networks/tree/main/bbn-test-5)

2. Or download directly using these commands:

```shell
wget https://github.com/babylonlabs-io/networks/raw/main/bbn-test-5/genesis.tar.bz2 # TODO: update this file name if necessary
tar -xjf genesis.tar.bz2 && rm genesis.tar.bz2
mv genesis.json ~/<path>/config/genesis.json #insert your --home 
```

>Note: Verify that the `chain-id` in the genesis file matches the one used in 
your initialization command (`bbn-test-5`). This ensures your node connects 
to the correct network.

## Create a Keyring

Keys are a fundamental component of your node's identity within the 
Babylon network. This cryptographic key-pair serves multiple critical functions: 
it allows you to interact with the network, send transactions, and manage your account. 
Creating and securing your keys is one of the most important steps in setting up your node.

To generate your key, use the following command:

```shell
babylond --keyring-backend test keys add <name> --home <path>
```
In this example, we use `--keyring-backend test`, that specifies 
the usage of the `test` backend which stores the keys unencrypted on disk.

Alternatively, there are three options for the keyring backend:

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

Make sure to securely store this information, particularly your 
address and private key details. Losing access to these credentials 
would mean losing access to your account and any funds associated with it.

## Sync Node

We are now ready to sync the node.

```shell
babylond start --chain-id bbn-test-5 --home <path> --x-crisis-skip-assert-invariants
```

Lets go through the flags of the above command:

- `start`: This is the command to start the Babylon node.
- `--chain-id`: Specifies the ID of the blockchain network you're connecting to.
- `--home`: Sets the directory for the node's data and configuration files and 
is dependant on where the files were generated for you from the initialization 
(e.g. `--home ./nodeDir`)

### Options for Syncing

You have two options for syncing your node:

1. **Sync through Network Peers**
   - Use the seed node configuration mentioned earlier in `config.toml`
   - Additional peers can be added under the `persistent_peers` setting
   <!-- Add peer list when available -->

2. **Sync from Snapshot**
   - For faster syncing, you can use a snapshot instead of syncing from genesis
   - Snapshots are periodic backups of the chain state
   - Find available snapshots at: <!-- Add link when available -->
   
   Note: Always verify snapshot sources and checksums before using them to ensure security.

## Get Funds

To interact with the Babylon network, you'll need some BBN tokens to:
1. Pay for transaction fees (gas)
2. Send transactions
3. Participate in network activities

You can obtain testnet tokens through two methods:

1. Request funds from the Babylon Testnet Faucet 
[here](#tbd)

2. Join our Discord server and visit the #faucet channel: 
[Discord Server](https://discord.com/channels/1046686458070700112/1075371070493831259)

Note: These are testnet tokens with no real value, used only for testing 
and development purposes.

## Security Recommendations

<!-- TODO: add security recommendations -->

## Next Steps

For information about becoming a Finality Provider in the Babylon network, 
see our [Finality Provider Guide](../babylon-validators/README.md).