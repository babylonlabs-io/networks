# Babylon Node Setup

## Table of Contents

1. [Install Babylon Binary](#1-install-babylon-binary)
2. [Set Up Node Home Directory and Configuration](#2-set-up-your-node-home-directory-and-configuration)
3. [Sync Node](#3-sync-node)

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
- `<moniker>` is a unique identifier for your node (e.g. `node0`).
- `--home` *optional* flag that specifies the directory where your 
node files will be stored (e.g. `--home ./nodeDir`).
- `--chain-id` is the chain ID of the Babylon chain you connect to. You should 
   use `bbn-test-5`. 

After initialization, you'll need to modify the following configuration files:

1. First, open `app.toml` and update these the following settings:

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

Navigate to `config.toml`. Add in your seed, as shown below:

```shell
 #P2P Configuration Options    

# Comma separated list of seed nodes to connect to
seeds = "8fa2d1ab10dfd99a51703ba760f0ef555ae88f36@16.162.207.201:26656" 
# This is only an example of the testnet seed and should be replaced with the actual seed node.
```
Please refer to our [network specification page](../README.md)
to find the latest seed node and sync details.

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

## 3. Sync Node

<!-- TODO: update accordingly with the new sync method when available -->

Node operators have the option to sync either from
genesis or through a snapshot:

<!-- TODO: the below does not seem right -->
1. **Sync through Network Peers**
   - Use the seed node configuration mentioned earlier in `config.toml`
   - Additional peers can be added under the `persistent_peers` setting
   <!-- Add peer list when available -->
2. **Sync from Snapshot**
   - For faster syncing, you can use a snapshot instead of syncing from genesis
   - Snapshots are periodic backups of the chain state
   - Find available snapshots at: <!-- Add link when available -->

> ⚠️ **Important**: Always verify snapshot sources and checksums before using 
them to ensure security.

<!-- TODO: we do not have a smooth transition to this from before -->
We are now ready to sync the node. To do this run the following command:

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

Congratulations! Your Babylon node is now set up and syncing with the network.