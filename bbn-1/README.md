# Babylon Mainnet

Welcome to the network page for the Babylon mainnet.
This is your central hub 
for network participation information, whether you're running a node, 
operating as a validator, providing finality services, or participating 
in the covenant committee.

## Babylon Genesis Chain (Phase-2 Mainnet)

### Network Parameters

#### Chain ID

`bbn-1`

#### Genesis

The genesis file can be retrieved from [here](./network-artifacts/genesis.json).

#### State snapshot

A snapshot including state up to height `226` can be retrieved from
[here](./network-artifacts/bbn-1.tar.gz).

To boot a node with this snapshot, Babylon version `v1.0.1` should be used
([reference](https://github.com/babylonlabs-io/babylon/releases/tag/v1.0.1)).


Some additional network snapshot sources are also listed:

- https://babylon.explorers.guru/snapshots
- https://polkachu.com/babylon_partnership

#### Seed nodes

Seed nodes can be retrieved from [here](./network-artifacts/seeds.txt).

#### Peers

Peers can be retrieved from [here](./network-artifacts/peers.txt).

#### Endpoints

##### RPC

Pruned:
- https://babylon.nodes.guru/rpc
- https://babylon-rpc.polkachu.com

Archive:
- https://babylon-archive.nodes.guru/rpc
- https://babylon-archive-rpc.polkachu.com

##### LCD (node API)

Pruned:
- https://babylon.nodes.guru/api
- https://babylon-api.polkachu.com

Archive:
- https://babylon-archive.nodes.guru/api
- https://babylon-archive-api.polkachu.com

##### gRPC

Pruned:
- babylon.nodes.guru:443
- babylon-grpc.polkachu.com:20690

Archive:
- babylon-archive.nodes.guru:443
- babylon-archive-grpc.polkachu.com:20690

### Babylon Genesis network participants

There are four types of participants in the Babylon network.
Please see the setup and configuration guides below:

- [Babylon Node Operators](babylon-node/README.md)
- [Validators](babylon-validators/README.md)
- [Finality Providers](https://github.com/babylonlabs-io/finality-provider/blob/main/README.md)
- [Covenant Committee](https://github.com/babylonlabs-io/covenant-emulator/blob/main/README.md)

## Phase-1 Mainnet

With the launch of the Babylon Genesis chain mainnet, the Babylon mainnet
will enter into a transitionary stage in which Phase-1 stakes will either
register on the Babylon Genesis chain or on-demand unbond and withdraw.
After the launch of the Babylon Genesis chain mainnet, the Phase-1 mainnet will
be considered legacy without any new staking caps planned or stakes accepted.

> **⚠️ Warning**: The Babylon Genesis mainnet has not yet launched, so the
> Phase-1 mainnet still remains the current supported Babylon mainnet.
