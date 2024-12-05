# Babylon Node Setup

## Table of Contents

1. [Install Babylon Binary](#1-install-babylon-binary)
2. [Set Up Node Home Directory and Configuration](#2-set-up-your-node-home-directory-and-configuration)
3. [Prepare for sync](#3-sync-node)
  1. [Sync through a network snapshot](#31-sync-through-a-network-snapshot)
  2. [Sync through state sync](#32-sync-through-state-sync)
  3. [Sync from scratch](#33-sync-from-scratch)
4. [Start the node](#4-start-the-node)

## 1. Install Babylon Binary 

1. Install [Golang 1.23](https://go.dev/dl)
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
- `<moniker>` is a unique identifier for your node (e.g. `node0`)
- `--home` *optional* flag that specifies the directory where your 
node files will be stored (e.g. `--home ./nodeDir`)
- `--chain-id` is the chain ID of the Babylon chain you connect to

After initialization, you'll need to modify the following configuration files:

1. On `app.toml`, update these the following settings:

```shell
# Base configuration
# Minimum gas prices that this node will accept
minimum-gas-prices = "0.005ubbn"

iavl-cache-size = 0
iavl-disable-fastnode=true

[btc-config]

# Configures which bitcoin network should be used for checkpointing
# valid values are: [mainnet, testnet, simnet, signet, regtest]
network = "signet" # The Babylon testnet connects to the signet Bitcoin network
```

In the above configuration, we disable IAVL cache to make the node utilize less 
memory.
In case of a node serving heavy RPC query load, these settings shouldn't be used.

<!-- TODO: Add a link to the seed file once the PR is merged -->
2. On `config.toml`, populate your seed nodes using entries from this list:

```shell
# P2P Configuration Options    

# This is only an example and should be replaced with actual testnet seed
# nodes.
# Comma separated list of seed nodes to connect to
seeds = "8fa2d1ab10dfd99a51703ba760f0ef555ae88f36@16.162.207.201:26656" 
```

Next, you'll need to obtain the network's genesis file. This file contains 
the initial state of the blockchain and is crucial for successfully syncing 
your node. You can get it from:

1. The Babylon Networks repository: [bbn-test-5](../genesis.tar.bz2)
2. Or download directly using these commands:
```shell
wget https://github.com/babylonlabs-io/networks/raw/main/bbn-test-5/genesis.tar.bz2 
tar -xjf genesis.tar.bz2 && rm genesis.tar.bz2
mv genesis.json <path>/config/genesis.json # insert the home directory of your node
```

Additionally, verify that the `chain-id` in the genesis file matches the one used in 
your initialization command (`bbn-test-5`). This ensures your node connects 
to the correct network.

## 3. Prepare for sync

<!-- TODO: Specify height and version -->
Testnet-5 underwent a software upgrade at height `X`, upgrading babylond from
[v0.9.0](https://github.com/babylonlabs-io/babylon/releases/tag/v0.9.0) to
`vA.B.C`.

We will analyze several strategies below to sync your node in accordance with
this event.

### 3.1. Sync through a network snapshot

<!-- TODO: Specify height -->
You can obtain the network snapshot containing blocks up to height `X` from
[here](./network-artifacts/bbn-test-5.tar.gz).

<!-- TODO: We can add other snapshot sources as they appear -->

To extract the snapshot, utilize the following command:

```shell
tar -xvf bbn-test-5.tar.gz -C <path>
```

, where <path> your node's home directory.

After importing the state, you can now start your node as specified in section
[Start the node](#4-start-the-node).

### 3.2. Sync through state sync

State sync allows your node to quickly catch up to the current state without
downloading and verifying the entire blockchain history.

To utilize state sync, you'll need to update a few flags in your `config.toml`:

<!-- TODO: Add state-sync server from Nodes.Guru, height and hash-->
```shell
[statesync]
enable = true

rpc_servers = "Y"
trust_height = X
trust_hash = "Z"
```

In the above configuration, we've specified `X` as the upgrade height. You can
use any **later** height of your choice as well, updating the trust hash
accordingly.

You can now start your node as specified in section
[Start the node](#4-start-the-node).

### 3.3. Sync from scratch

Is it also possible to sync from scratch, i.e., block `1`. This will require
you to use 2 different babylond binaries and perform the babylon software
upgrade when needed.

Initially, install babylon
[v0.9.0](https://github.com/babylonlabs-io/babylon/releases/tag/v0.9.0) and
start your node as specified in section [Start the node](#4-start-the-node).

<!-- TODO: Specify height -->
Your node will start syncing blocks and will halt at height `X`, which is the
height that the software upgrade occurred.

<!-- TODO: Add log -->

<!-- TODO: Specify version -->
At this point, you can install babylon
`vA.B.C` and restart your node. Your node will then start syncing the rest of
the blocks.

## 4. Start the node

You can start your node in the following manner:

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
