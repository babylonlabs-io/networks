# Babylon testnet-5 Network

Welcome to the network page for the Babylon Phase-2 testnet (`bbn-test-5`).
This is your central hub 
for network participation information, whether you're running a node, 
operating as a validator, providing finality services, or participating 
in the covenant committee.

## Network Parameters

### Chain ID

`bbn-test-5`

### Genesis

The genesis file can be retrieved from [here](./network-artifacts/genesis.json).

### State snapshot

A snapshot including state up to height `200` can be retrieved from
[here](./network-artifacts/bbn-test-5.tar.gz).

To boot a node with this snapshot, Babylon version `v1.0.0-rc.3` should be used
([reference](https://github.com/babylonlabs-io/babylon/releases/tag/v1.0.0-rc.3)).

Some additional network snapshot sources are also listed:

- https://polkachu.com/testnets/babylon/snapshots
- https://www.imperator.co/services/chain-services/testnets/babylon

### Seed nodes

Seed nodes can be retrieved from [here](./seeds.txt).

### Peers

Peers can be retrieved from [here](./peers.txt).

### Endpoints

1. RPC

- https://babylon-testnet-rpc.nodes.guru
- https://babylon-testnet-rpc.polkachu.com
- https://rpc-babylon-testnet.imperator.co

2. LCD (node API)

- https://babylon-testnet-api.nodes.guru
- https://babylon-testnet-api.polkachu.com
- https://lcd-babylon-testnet.imperator.co

3. gRPC

- https://babylon-testnet-grpc.nodes.guru
- http://babylon-testnet-grpc.polkachu.com:20690
- grpc-babylon-testnet.imperator.co:443

## Network Participants

There are four types of participants in the Babylon network.
Please see the setup and configuration guides below:

- [Babylon Node Operators](babylon-node/README.md)
- [Validators](babylon-validators/README.md)
- [Finality Providers](https://github.com/babylonlabs-io/finality-provider/blob/main/README.md)
- [Covenant Committee](https://github.com/babylonlabs-io/covenant-emulator/blob/main/README.md)
