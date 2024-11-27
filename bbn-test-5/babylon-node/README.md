# Babylon Node Setup

## Table of Contents

1. [Install Babylon Binary](#1-install-babylon-binary)
2. [Setup Node Home Directory and Configuration](#2-setup-your-node-home-directory-and-configuration)
3. [Sync Node](#3-sync-node)
   1. [Options for Syncing](#31-options-for-syncing)
4. [Monitoring Your Node](#4-monitoring-your-node)
5. [Security Recommendations](#5-security-recommendations)
6. [Next Steps](#6-next-steps)

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
- Makes the `babylond` command globally accessible from your terminal

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

If your shell cannot find the installed binary, make sure `$GOPATH/bin` is in 
your shell's `$PATH`. Use the following commnd to add it to your profile, 
depending on your shell:
 ```shell 
 echo 'export PATH=$HOME/go/bin:$PATH' >> ~/.profile 
 ```

## 2. Setup your node, home directory, and configuration

In this section we will initialize your node and create the necessary 
configuration directory. This command will generate several important configuration files 
including `app.toml`, `client.toml`, and `genesis.json`:

```shell
babylond init <moniker> --chain-id bbn-test-5 --home <path>
```

Parameters:
- `<moniker>` is a unique identifier for your node (e.g. `node0`).
- `--home` flag specifies the directory where your node files will be stored 
   (e.g. `--home ./nodeDir`).
- `--keyring-backend` is the backend for keyring, can be `test`, `file`, or `os`.

After initialization, you'll need to modify the following configuration files:

1. First, open `app.toml` and update these the following settings:

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

In the above configuration, we disable IAVL cache to make the node utilize less memory.
In case of a node serving heavy RPC query load, these settings shouldn't be used.

Navigate to `config.toml`. Add in your seed, as shown below:

```shell
 #P2P Configuration Options    

# Comma separated list of seed nodes to connect to
seeds = "8fa2d1ab10dfd99a51703ba760f0ef555ae88f36@16.162.207.201:26656" 
# This is only an example of the testnet seed and should be replaced with the actual seed node.
```
Please head to [Nodes.Guru](https://nodes.guru) for the latest seed node.
<!-- update with link to seed node when available -->

Next, you'll need to obtain the network's genesis file. This file contains 
the initial state of the blockchain and is crucial for successfully syncing 
your node. You can get it from:

1. The official Babylon Networks repository: [bbn-test-5](https://github.com/babylonlabs-io/networks/tree/main/bbn-test-5)

2. Or download directly using these commands:

```shell
wget https://github.com/babylonlabs-io/networks/raw/main/bbn-test-5/genesis.tar.bz2 # TODO: update this file name if necessary
tar -xjf genesis.tar.bz2 && rm genesis.tar.bz2
mv genesis.json <path>/config/genesis.json #insert your --home <path>
```

Additionally, verify that the `chain-id` in the genesis file matches the one used in 
your initialization command (`bbn-test-5`). This ensures your node connects 
to the correct network.

## 3. Sync Node

We are now ready to sync the node, to this run the following command:

```shell
babylond start --chain-id bbn-test-5 --home <path> --x-crisis-skip-assert-invariants
```

Parameters:

- `start`: This is the command to start the Babylon node.
- `--chain-id`: Specifies the ID of the blockchain network you're connecting to.
- `--home`: Sets the directory for the node's data and configuration files and 
   s dependant on where the files were generated for you from the initialization 
   (e.g. `--home ./nodeDir`)

### 3.1 Options for Syncing
<!-- TODO: update accordingly with the new sync method when available -->

Due to us moving to the next phase of the testnet, we will either need operators 
to sync from genesis or use a snapshot.

You will see instructions below on how for both methods.

1. **Sync through Network Peers**
   - Use the seed node configuration mentioned earlier in `config.toml`
   - Additional peers can be added under the `persistent_peers` setting
   <!-- Add peer list when available -->

2. **Sync from Snapshot**
   - For faster syncing, you can use a snapshot instead of syncing from genesis
   - Snapshots are periodic backups of the chain state
   - Find available snapshots at: <!-- Add link when available -->
   
> ⚠️ **Important**: Always verify snapshot sources and checksums before using them to ensure security.

## 4. Monitoring Your Node

Your Babylon node exposes metrics through two Prometheus endpoints:
- `Port 1317`: API metrics
- `Port 26660`: CometBFT metrics

To enable metric collection, modify your `app.toml`:
```
[telemetry]
enabled = true
prometheus-retention-time = 600 # 10 minutes
[api]
enable = true
address = "0.0.0.0:1317"
```

Basic health monitoring should check:
- Node synchronization status
- Block height compared to network
- Connected peers count
- System resource usage (CPU, RAM, Disk)

## 5. Security Recommendations

1. **Secure Key Management**
   - Store keys in a separate, encrypted storage system
   - Currently no secure keyring backend is supported for production use
   - Offline backups

2. **Network Security**
   - Only expose necessary gRPC, REST, and CometBFT Endpoints in app.toml and config.toml
   as seen [here](https://docs.cosmos.network/main/learn/advanced/grpc_rest)
   - Configure rate limiting in your reverse proxy (nginx/caddy) for public endpoints
   - Use SSL/TLS certificates when exposing endpoints externally

3. **System Security**
   - Keep the host system updated
   - Monitor system logs for suspicious activity

4. **Performance Considerations**
   - The node handles approximately 2,500 RPS on the native Cosmos SDK RPC endpoints
   - Monitor resource usage during peak periods
   - Ensure adequate disk space for chain growth
   - Set up alerts for resource thresholds

## 6.Next Steps

For information about becoming a Finality Provider in the Babylon network, 
see our [Finality Provider Guide](../babylon-validators/README.md).