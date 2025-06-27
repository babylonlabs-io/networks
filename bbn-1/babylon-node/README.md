# Babylon Node Setup

## Table of Contents

1. [Full automatic installation](#1-full-autoinstallation)
2. [Install Babylon binary](#2-install-babylon-binary)
3. [Set up node](#3-set-up-your-node)
4. [Prepare for sync](#4-prepare-for-sync)
    1. [Sync through a network snapshot](#41-sync-through-a-network-snapshot)
    2. [Sync from scratch](#42-sync-from-scratch)
5. [Start the node](#5-start-the-node)
    1. [Start your node from CLI](#51-start-your-node-from-cli)
    2. [Start your node using a service file](#52-start-your-node-using-a-service-file)

## 1. Full Autoinstallation
To install the node with one command, run:
```shell
source <(curl -s https://itrocket.net/api/mainnet/babylon/autoinstall/)
```

This command:
- installs all the necessary dependencies;
- installs the binary;
- configures the node (edits configuration files, downloads genesis and addrbook, sets seeds and peers);
- downloads a snapshot;
- runs the node with a service file.

## 2. Install Babylon Binary

Before installation, set the variables:
```shell
# set vars
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export WALLET="wallet"" >> $HOME/.bash_profile
echo "export MONIKER="test"" >> $HOME/.bash_profile
echo "export BABYLON_CHAIN_ID="bbn-1"" >> $HOME/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
```

Installing the Babylon binary requires a Golang installation.

Install Golang 1.23 by following the instructions
[here](https://go.dev/dl) or run the following:
```shell
cd $HOME
VER="1.23.1"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
```

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
git checkout v2.1.0
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
v2.1.0
 ```

Note: Alternatively, you can use a
[Docker image](https://hub.docker.com/layers/babylonlabs/babylond/v1.0.1/images/sha256-8650aca16af767d844de62d45ff989637aa6009d7d71d19f5a0d2b86198cda94)

## 3. Set up your node

In this section we will initialize your node and create the necessary configuration directory through the `init` command. Replace `<path>` with the directory where your node files will be stored:

```shell
babylond init $MONIKER --chain-id $BABYLON_CHAIN_ID --home <path>
sed -i \
-e "s/chain-id = .*/chain-id = \"${BABYLON_CHAIN_ID}\"/" \
-e "s/keyring-backend = .*/keyring-backend = \"os\"/" $HOME/.babylond/config/client.toml
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

After initialization, you'll need to modify `app.toml` and `config.toml` configuration files.

1. On `app.toml`, update the following parameters:
- `minimum-gas-prices`: The minimum gas price your node will accept for
  transactions. The Babylon protocol enforces a minimum of `0.002ubbn` and
  any transactions with gas prices below your node's minimum will be rejected.
- `mempool.max-txs`: Set this to `0` in order to utilise the application side
  mempool.
- `btc-config.network`: Specifies which Bitcoin network to connect to for
  checkpointing. For the Babylon Genesis mainnet,
  we use "mainnet" which is Bitcoin's mainnet network.

To update them, run:
```shell
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.002ubbn"|g' $HOME/.babylond/config/app.toml
sed -i 's|mempool.max-txs =.*|mempool.max-txs = 0|g' $HOME/.babylond/config/app.toml
sed -i 's|btc-config.network =.*|btc-config.network = "mainnet"|g' $HOME/.babylond/config/app.toml
```

Note: If you're running a validator or RPC node that needs to handle queries,
it's recommended to keep these default values for optimal performance. Only
adjust these if you're running a node with limited memory resources.

2. On `config.toml`, update the the following parameters:
- `seeds`: Comma separated list of seed nodes that your node will connect to for
   discovering other peers in the network;
- `persistent_peers`: Comma separated list of nodes that your node will use as
   persistent peers;
- `timeout_commit`: The Babylon Genesis network block time has to be set to
   **9200 milliseconds**. We set a lower value than the target 10s block time,
   to account for network delays.

To update them, run:
```shell
SEEDS="42fad8afbf7dfca51020c3c6e1a487ce17c4c218@babylon-seed-1.nodes.guru:55706,ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@seeds.polkachu.com:20656,145ee7d64ae5d3f6a8ceb6b7dba889f7de48de06@babylon-mainnet-seed.itrocket.net:27656"
PEERS="f0d280c08608400cac0ccc3d64d67c63fabc8bcc@91.134.70.52:55706,4c1406cb6867232b7ea130ed3a3d25996ca06844@23.88.6.237:20656,b40a147910a608018c47a0e0225106d00d2651ed@5.9.99.42:20656,184db83783c9158a3e99809ffed3752e180597be@65.108.205.121:20656,1f06b55dfbae181fa40ec08fe145b3caef6d3c83@5.9.81.54:2080,7d728de314f9746e499034bfcfc5a9023c672df5@84.32.32.149:18800,b16397b576f2431c8a80efa4f5338c1b82583916@babylon-mainnet-peer.itrocket.net:27656"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" \
       -e "/^\[consensus\]/,/^\[/{s/^[[:space:]]*timeout_commit *=.*/timeout_commit = \"9200ms\"/}" \
       $HOME/.babylond/config/config.toml
```
Note: You can use either seeds, persistent peers or both. Seeds can be obtained from [here](../README.md#seed-nodes), while peers can be found [here](../README.md#peers).

3. (Optional) Additionally, you can set custom ports.
Set your port for the `BABYLON_PORT` variable instead of `27`:
```shell
echo 'export BABYLON_PORT="27"' >> $HOME/.bash_profile
source $HOME/.bash_profile

sed -i.bak -e "s%:1317%:${BABYLON_PORT}317%g; s%:9090%:${BABYLON_PORT}090%g" $HOME/.babylond/config/app.toml
sed -i "s|^node *=.*|node = \"tcp://localhost:${BABYLON_PORT}657\"|" $HOME/.babylond/config/client.toml
sed -i.bak -e "s%:26658%:${BABYLON_PORT}658%g;
s%:26657%:${BABYLON_PORT}657%g;
s%:6060%:${BABYLON_PORT}060%g;
s%:26656%:${BABYLON_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${BABYLON_PORT}656\"%;
s%:26660%:${BABYLON_PORT}660%g" $HOME/.babylond/config/config.toml
```
Next, you'll need to obtain the network's genesis file. This file contains
the initial state of the blockchain and is crucial for successfully syncing
your node. You can inspect the file [here](../README.md#genesis) or use the
following commands to download it directly:

```shell
wget -O $HOME/.babylond/config/genesis.json https://raw.githubusercontent.com/babylonlabs-io/networks/refs/heads/main/bbn-1/network-artifacts/genesis.json
```

## 4. Prepare for sync

Before starting your node sync, it's important to note that the initial release
at genesis was `v0.9.0`, while subsequently there have been software upgrades.

There are two options you can choose from when syncing:
1. Sync through a network snapshot (fastest method)
2. Sync from scratch (complete sync from block 1)

### 4.1. Sync through a network snapshot

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

### 4.2. Sync from scratch

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

## 5. Start the node

You can start your node from CLI or configure it with a service file.

### 5.1. Start your node from CLI
For non-validator nodes:
```shell
babylond start --chain-id $BABYLON_CHAIN_ID --home $HOME/.babylond --x-crisis-skip-assert-invariants
```

For validator nodes:
```shell
babylond start --chain-id $BABYLON_CHAIN_ID --home $HOME/.babylond --bls-password-file="$HOME/.babylond/config/bls_password.txt
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

### 5.2. Start your node using a service file

Create a service file:
```shell
sudo tee /etc/systemd/system/babylond.service > /dev/null <<EOF
[Unit]
Description=Babylon node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.babylond
ExecStart=$(which babylond) start --home $HOME/.babylond --bls-password-file="$HOME/.babylond/config/bls_password.txt"
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

Enable and start service:
```shell
sudo systemctl daemon-reload
sudo systemctl enable babylond
sudo systemctl restart babylond && sudo journalctl -u babylond -fo cat
```

Congratulations! Your Babylon node is now set up and syncing blocks.
