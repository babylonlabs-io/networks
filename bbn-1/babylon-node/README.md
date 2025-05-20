# Babylon Node Setup

## Table of Contents

1. [Install Babylon binary](#1-install-babylon-binary)
2. [Set up node home directory and configuration](#2-set-up-your-node-home-directory-and-configuration)
3. [Prepare for sync](#3-prepare-for-sync)
    1. [Sync through a network snapshot](#31-sync-through-a-network-snapshot)
    2. [Sync from scratch](#32-sync-from-scratch)
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
git clone https://github.com/babylonlabs-io/babylon.git
cd babylon
# tag corresponds to the version of the software
# you want to install -- depends on which
# height you sync from
git checkout v1.0.1
# install the binary
make install
```
This command does the following:
- Builds the daemon
- Installs the binary
- Makes the `babylond` command globally accessible from your terminal

You can verify your installation by executing the `version` command:

```shell
babylond version
v1.0.1
```

If your shell cannot find the installed binary, make sure `$GOPATH/bin` is in
your shell's `$PATH`. Use the following command to add it to your profile,
depending on your shell:
 ```shell
echo 'export PATH=$HOME/go/bin:$PATH' >> ~/.profile
 ```

Make sure to restart your terminal session after running the above command.

Note: Alternatively, you can use a
[Docker image](https://hub.docker.com/layers/babylonlabs/babylond/v1.0.1/images/sha256-8650aca16af767d844de62d45ff989637aa6009d7d71d19f5a0d2b86198cda94)

## 2. Set up your node

In this section we will initialize your node and create the necessary
configuration directory through the `init` command.

```shell
babylond init <moniker> --chain-id bbn-1 --home <path>
```

Parameters:
- `<moniker>`: A unique identifier for your node for example `node0`
- `--chain-id`: The chain ID of the Babylon chain you connect to
- `--home`: *optional* flag that specifies the directory where your
  node files will be stored, for example `--home ./nodeDir`
  The default home directory for your Babylon node is:
   - Linux/Mac: `~/.babylond/`
   - Windows: `%USERPROFILE%\.babylond\`

> **⚠️  Important note about BLS keys**
>
> A prompt will appear for you to enter a password for a BLS key.
> This password will be used to encrypt your BLS key before storing it in a
> file (`$HOME/config/bls_key.json`).
> All node operators intending to become validators must have a BLS key,
> similar to the requirement for a `priv_validator_key.json` file.
> Babylon uses both the `bls_key.json` and the `priv_validator_key.json` files.
>
> You can specify your BLS password using the following options:
> * **CLI or Environment Variable**: You can specify your password through the
>   CLI or an environment variable (note that if both are used concurrently, an
>   error will be raised):
>   * **Environment Variable**: `BABYLON_BLS_PASSWORD` is set.
>   * **CLI flags**: One of the following CLI options has been set:
>     * `--no-bls-password` is a flag that if set designates that an empty BLS
>       password should be used.
>     * `--bls-password-file=<path>` allows to specify a file location that
>       contains the plaintext BLS password.
> * **(Recommended) Password Prompt**
>   If none of the above is set, a prompt will appear asking you to type your
>   password.

```
$HOME/.babylond/
├── config/
│   ├── app.toml         # Application-specific configuration
│   ├── bls_key.json     # BLS key for the node
│   ├── bls_password.txt # Password file for the BLS key (if `--bls-password-file` has been set)
│   ├── client.toml      # Client configuration
│   ├── config.toml      # Tendermint core configuration
│   ├── genesis.json     # Genesis state of the network
│   ├── node_key.json    # Node's p2p identity key
│   └── priv_validator_key.json  # Validator's consensus key (if running a validator)
├── data/                # Blockchain data directory
│   └── ...
└── keyring-test/       # Key management directory
    └── ...
```

After initialization, you'll need to modify the following configuration files:

1. On `app.toml`, update the following settings:

```shell
# Base configuration
# Minimum gas prices that this node will accept
minimum-gas-prices = "0.002ubbn"

[mempool]
# Setting max-txs to 0 will allow for a unbounded amount of transactions in the mempool.
# Setting max_txs to negative 1 (-1) will disable transactions from being inserted into the mempool (no-op mempool).
# Setting max_txs to a positive number (> 0) will limit the number of transactions in the mempool, by the specified amount.
#
# Note, this configuration only applies to SDK built-in app-side mempool
# implementations.
max-txs = 0

[btc-config]

# Configures which bitcoin network should be used for checkpointing
# valid values are: [mainnet, testnet, simnet, signet, regtest]
network = "mainnet" # The Babylon Genesis mainnet connects to the mainnet Bitcoin network
```

Parameters:
- `minimum-gas-prices`: The minimum gas price your node will accept for
  transactions. The Babylon protocol enforces a minimum of `0.002ubbn` and
  any transactions with gas prices below your node's minimum will be rejected.
- `mempool.max-txs`: Set this to `0` in order to utilise the application side
  mempool.
- `btc-config.network`: Specifies which Bitcoin network to connect to for
  checkpointing. For the Babylon Genesis mainnet,
  we use "mainnet" which is Bitcoin's mainnet network.

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

timeout_commit = "9200ms"
```

Parameters:
- `seeds`: Comma separated list of seed nodes that your node will connect to for
   discovering other peers in the network; you can obtain seed endpoints from
   [here](../README.md#seed-nodes)
- `persistent_peers`: Comma separated list of nodes that your node will use as
   persistent peers; you can obtain peers from [here](../README.md#peers)
- `timeout_commit`: The Babylon Genesis network block time has to be set to
   **9200 milliseconds**. We set a lower value than the target 10s block time,
   to account for network delays.

Note: You can use either seeds, persistent peers or both.

Next, you'll need to obtain the network's genesis file. This file contains
the initial state of the blockchain and is crucial for successfully syncing
your node. You can inspect the file [here](../README.md#genesis) or use the
following commands to download it directly:

```shell
wget
https://raw.githubusercontent.com/babylonlabs-io/networks/refs/heads/main/bbn-1/network-artifacts/genesis.json
mv genesis.json <path>/config/genesis.json # You must insert the home directory of your node
```

## 3. Prepare for sync

Before starting your node sync, it's important to note that the initial release
at genesis was `v0.9.0`, while subsequently there have been software upgrades.

There are two options you can choose from when syncing:
1. Sync through a network snapshot (fastest method)
2. Sync from scratch (complete sync from block 1)

### 3.1. Sync through a network snapshot

Snapshot syncing is the fastest way to get your node up to date with the network.
A snapshot is a compressed backup of the blockchain data taken at a specific
height. Instead of processing all blocks from the beginning, you can download
and import this snapshot to quickly reach a recent block height.

You can obtain the network snapshot [here](../README.md#state-snapshot).

To extract the snapshot, utilize the following command:

```shell
tar -xvf bbn-1.tar.gz -C <path>
```

Parameters:
- `bbn-1.tar.gz`: Name of the compressed blockchain snapshot file
- `<path>` : Your node's home directory

After importing the state, you can now start your node as specified in section
[Start the node](#4-start-the-node).

### 3.2. Sync from scratch

> **Important**: If you decide to sync from scratch and target to become a
> validator, do not create a BLS key before
> upgrading to a version that is `> 1.0.0`.

Lastly, you can also sync from scratch, i.e., sync from block `1`. Syncing from
scratch means downloading and verifying every block from the beginning
of the blockchain (genesis block) to the current block.

This will require you to use different `babylond` binaries for each version and
perform the babylon software upgrade when needed.

1. First, follow the installation steps in [Section 1](#1-install-babylon-binary)
using the genesis software version `v0.9.0` in place of `<tag>`.

2. Start your node as specified in section [Start the node](#4-start-the-node).

Your node will sync blocks until it reaches a software upgrade height.

At that point, you will have to perform the steps matching the corresponding
[upgrade height](../network-artifacts/upgrades/README.md).

Note: When building the upgrade binary, include the following build flag so that
mainnet-specific upgrade data are included in the binary:

```shell
BABYLON_BUILD_OPTIONS="mainnet" make install
```

You will have to go over all the software upgrades until you sync with the
full blockchain.

## 4. Start the node

You can start your node using the following command:

```shell
babylond start --chain-id bbn-1 --home <path> --x-crisis-skip-assert-invariants
```

Parameters:
- `start`: This is the command to start the Babylon node.
- `--chain-id`: Specifies the ID of the blockchain network you're connecting to.
- `--home`: Sets the directory for the node's data and configuration files and
   dependent on where the files were generated for you from the initialization
   (e.g. `--home ./nodeDir`)
- `--x-crisis-skip-assert-invariants`: Skips state validation checks to improve
   performance. Not recommended for validator nodes.

> **⚠️  Important note about BLS keys**
>
> The `start` command will need to decrypt and load your BLS key, which
> requires your BLS key password. As with the `init` command,
> you can specify your BLS password using the following options:
> * **CLI or Environment Variable**: You can specify your password through the
>   CLI or an environment variable (note that if both are used concurrently, an
>   error will be raised):
>   * **Environment Variable**: `BABYLON_BLS_PASSWORD` is set.
>   * **CLI flags**: One of the following CLI options has been set:
>     * `--no-bls-key` is a flag that if set designates that an empty BLS
>       password should be used.
>     * `--bls-password-file=<path>` allows to specify a file location that
>       contains the plaintext BLS password.
> * **(Recommended) Password Prompt**
>   If none of the above is set, a prompt will appear asking you to type your
>   password.

Congratulations! Your Babylon node is now set up and syncing blocks.
