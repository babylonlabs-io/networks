# Babylon Node Setup

## Table of Contents

1. [Install Babylon Binary](#1-install-babylon-binary)
2. [Set Up Node Home Directory and Configuration](#2-set-up-your-node-home-directory-and-configuration)
3. [Prepare for sync](#3-prepare-for-sync)
   1. [Sync through a network snapshot](#31-sync-through-a-network-snapshot)
   2. [Sync through state sync](#32-sync-through-state-sync)
   3. [Sync from scratch](#33-sync-from-scratch)
4. [Start the node](#4-start-the-node)

## 1. Install Babylon Binary 

Installing the Babylon binary requires a Golang installation.

Install Golang 1.23 by following the instructions
[here](https://go.dev/dl)

Once installed, to verify your installation, run:
```shell
go version
```

Next, clone the Babylon codebase
and install the Babylon binary:

```shell
git clone git@github.com:babylonlabs-io/babylon.git
cd babylon
# tag corresponds to the version of the software
# you want to install -- depends on which
# height you sync from
git checkout <tag>
make install
```
<!-- TODO: testnet tag to be defined -->
This command does the following:
- Builds the daemon
- Installs the binary 
- Makes the `babylond` command globally accessible from your terminal

You can verify your installation by executing the `version` command:

```shell
babylond version
```

If your shell cannot find the installed binary, make sure `$GOPATH/bin` is in 
your shell's `$PATH`. Use the following command to add it to your profile, 
depending on your shell:
 ```shell 
 echo 'export PATH=$HOME/go/bin:$PATH' >> ~/.profile 
 ```

Make sure to restart your terminal session after running the above command.

## 2. Set up your node, home directory, and configuration

In this section we will initialize your node and create the necessary 
configuration directory through the `init` command.
This command will generate several important configuration files 
including `app.toml`, `client.toml`, and `genesis.json`:

```shell
babylond init <moniker> --chain-id bbn-test-5 --home <path>
```

Parameters:
- `<moniker>`: A unique identifier for your node for example `node0`
- `--chain-id`: The chain ID of the Babylon chain you connect to
- `--home`: *optional* flag that specifies the directory where your 
   node files will be stored, for example `--home ./nodeDir`
   The default home directory for your Babylon node is:
   - Linux/Mac: `~/.babylond/`
   - Windows: `%USERPROFILE%\.babylond\`

After initialization, you'll need to modify the following configuration files:

1. On `app.toml`, update the the following settings:

```shell
# Base configuration
# Minimum gas prices that this node will accept
minimum-gas-prices = "0.005ubbn"

iavl-cache-size = 0
iavl-disable-fastnode = true

[btc-config]

# Configures which bitcoin network should be used for checkpointing
# valid values are: [mainnet, testnet, simnet, signet, regtest]
network = "signet" # The Babylon testnet connects to the signet Bitcoin network
```

Parameters:
- `minimum-gas-prices`: The minimum gas price (in this example we use `0.005ubbn`)
   that your node will accept for transactions. Transactions with lower gas 
   prices will be rejected.
- `iavl-cache-size`: Default is `781250`. Setting to `0` disables the IAVL tree
   caching, which reduces memory usage but significantly impacts RPC query
   performance.
- `iavl-disable-fastnode`: Default is `false`. Setting to true disables the 
   fast node feature, which reduces memory usage but significantly 
   impacts RPC query performance.
- `btc-config.network`: Specifies which Bitcoin network to connect to for 
   checkpointing. For testnet-5, we use "signet" which is Bitcoin's test network.

Note: If you're running a validator or RPC node that needs to handle queries, 
it's recommended to keep these default values for optimal performance. Only 
adjust these if you're running a node with limited memory resources.

2. On `config.toml`, update the the following settings:

```shell
[p2p]

# These are placeholder values and should be replaced
seeds = "NODE_ID1@NODE_ENDPOINT1:PORT1,NODE_ID2@NODE_ENDPOINT2:PORT2"

# These are placeholder values and should be replaced
persistent_peers = "NODE_ID1@NODE_ENDPOINT1:PORT1,NODE_ID2@NODE_ENDPOINT2:PORT2"

[consensus]

timeout_commit = "10s"
```

Parameters:
- `seeds`: Comma separated list of seed nodes that your node will connect to for 
   discovering other peers in the network; you can obtain seed endpoints from
   [here](../README.md#seed-nodes)
- `persistent_peers`: Comma separated list of nodes that your node will use as
   persistent peers; you can obtain peers from [here](../README.md#peers)
- `timeout_commit`: The Babylon network block time has to be set to 
   **10 seconds**

Note: You can use either seeds, persistent peers or both.

Next, you'll need to obtain the network's genesis file. This file contains 
the initial state of the blockchain and is crucial for successfully syncing 
your node. You can inspect the file [here](../README.md#genesis) or use the 
following commands to download it directly:

```shell
wget https://raw.githubusercontent.com/babylonlabs-io/networks/refs/heads/main/bbn-test-5/network-artifacts/genesis.json
mv genesis.json <path>/config/genesis.json # You must insert the home directory of your node
```

## 3. Prepare for sync
Before starting your node sync, it's important to note that the initial release 
at genesis was `v0.9.0`, while subsequently there have been software upgrades.

There are three options you can choose from when syncing:
1. Sync through a network snapshot (fastest method)
2. Sync through state sync (quick catch-up without full history)
3. Sync from scratch (complete sync from block 1)

### 3.1. Sync through a network snapshot

Snapshot syncing is the fastest way to get your node up to date with the network. 
A snapshot is a compressed backup of the blockchain data taken at a specific 
height. Instead of processing all blocks from the beginning, you can download 
and import this snapshot to quickly reach a recent block height.

You can obtain the network snapshot [here](../README.md#state-snapshot).

To extract the snapshot, utilize the following command:

```shell
tar -xvf bbn-test-5.tar.gz -C <path>
```

Parameters:
- `bbn-test-5.tar.gz`: Name of the compressed blockchain snapshot file
- `<path>` : Your node's home directory

After importing the state, you can now start your node as specified in section
[Start the node](#4-start-the-node).

### 3.2. Sync through state sync

State sync downloads only the current blockchain state (account balances, 
validator set, and module states) instead of processing the entire chain history.
While this means you won't have historical data, state sync allows your node to 
quickly catch up to the current state without downloading and verifying the 
entire blockchain history. To find the state-sync server from our 
[networks homepage](../README.md).

To utilize state sync, you'll need to update a few flags in your `config.toml`:
```shell
[statesync]
enable = true

rpc_servers = "4fd0303f110abe7567f318be659ce3b99436e895@65.108.198.118:20656"
trust_height = 200
trust_hash = "4BCA43567339FD376F5C2C4DE75C4496181A0D169E79F65058D3EEDAAD714B6E"
```

Parameters:
- `enable`: Activates state sync functionality
- `rpc_servers`: List of RPC servers to fetch state sync data from
- `trust_height`: Block height to trust for state sync 
- `trust_hash`: Block hash corresponding to the trusted height

You can find the current state sync configuration values on our 
[networks homepage](../README.md#state-sync).

Once configured, proceed to [Start the node](#4-start-the-node).

### 3.3. Sync from scratch

Lastly, you can also sync from scratch, i.e., sync from block `1`. Syncing from 
scratch means downloading and verifying every block from the beginning 
of the blockchain (genesis block) to the current block.

This will require you to use different `babylond` binaries for each version and 
perform the babylon software upgrade when needed.

1. First, follow the installation steps in [Section 1](#1-install-babylon-binary)
using the genesis software version `v0.9.0` in place of `<tag>`. 

2. Start your node as specified in section [Start the node](#4-start-the-node).

Your node will sync blocks until it reaches an upgrade height.

At that point, you will have to get the new software version defined by that
height, and go back to step (1) in order to install it and restart.

Note: When building the upgrade binary, include the following build flag so that
testnet-specific upgrade data are included in the binary:

```shell
BABYLON_BUILD_OPTIONS="testnet" make install
```

You will have to repeat the above two steps until you sync with the 
full blockchain.

## 4. Start the node

You can start your node using the following command:

```shell
babylond start --chain-id bbn-test-5 --home <path> --x-crisis-skip-assert-invariants
```

Parameters:
- `start`: This is the command to start the Babylon node.
- `--chain-id`: Specifies the ID of the blockchain network you're connecting to.
- `--home`: Sets the directory for the node's data and configuration files and 
   dependent on where the files were generated for you from the initialization 
   (e.g. `--home ./nodeDir`)
- `--x-crisis-skip-assert-invariants`: Skips state validation checks to improve 
   performance. Not recommended for validator nodes.

Congratulations! Your Babylon node is now set up and syncing blocks.
