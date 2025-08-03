# Babylon Genesis Testnet Network

Welcome to the network page for the Babylon Genesis Testnet (`bbn-test-5`).
This is your central hub for network participation information, whether you're
running a node, Validator, Finality Provider, or Covenant Emulator.

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
- https://services.contributiondao.com/testnet/babylon/snapshots

### Seed nodes

Seed nodes can be retrieved from [here](./network-artifacts/seeds.txt).

### Peers

Peers can be retrieved from [here](./network-artifacts/peers.txt).

### Endpoints

1. RPC


Pruned:
- https://babylon-testnet-rpc.nodes.guru
- https://babylon-testnet-rpc.polkachu.com
- https://rpc-babylon-testnet.imperator.co
- https://babylon-testnet-rpc.contributiondao.com

Archive:
- https://babylon-testnet-rpc-archive-1.nodes.guru

2. LCD (node API)

Pruned:
- https://babylon-testnet-api.nodes.guru
- https://babylon-testnet-api.polkachu.com
- https://lcd-babylon-testnet.imperator.co
- https://babylon-testnet-api.contributiondao.com

Archive:
- https://babylon-testnet-api-archive-1.nodes.guru

3. gRPC

- https://babylon-testnet-grpc.nodes.guru
- http://babylon-testnet-grpc.polkachu.com:20690
- grpc-babylon-testnet.imperator.co:443

### Covenant Committee

The covenant committee consists of 9 signing keys with a quorum being achieved
with 6 signatures. Below are the members of the covenant committee and the
BTC public keys associated with them.

* Babylon Labs:
  * `fa9d882d45f4060bdb8042183828cd87544f1ea997380e586cab77d5fd698737`
  * `0aee0509b16db71c999238a4827db945526859b13c95487ab46725357c9a9f25`
  * `17921cf156ccb4e73d428f996ed11b245313e37e27c978ac4d2cc21eca4672e4`
* Cubist
  * `113c3a32a9d320b72190a04a020a0db3976ef36972673258e9a38a364f3dc3b0`
* Informal Systems
  * `79a71ffd71c503ef2e2f91bccfc8fcda7946f4653cef0d9f3dde20795ef3b9f0`
* Zellic
  * `3bb93dfc8b61887d771f3630e9a63e97cbafcfcc78556a474df83a31a0ef899c`
* RockX
  * `d21faf78c6751a0d38e6bd8028b907ff07e9a869a43fc837d6b3f8dff6119a36`
* AltLayer
  * `f5199efae3f28bb82476163a7e458c7ad445d9bffb0682d10d3bdb2cb41f8e8e`
* CoinSummer Labs
  * `40afaf47c4ffa56de86410d8e47baa2bb6f04b604f4ea24323737ddc3fe092df`

Alternatively, the list can be retrieved from [here](./covenant-committee.json).

## Network Participants

There are four types of participants in the Babylon network.
Please see the setup and configuration guides below:

- [Babylon Node Operators](babylon-node/README.md)
- [Validators](babylon-validators/README.md)
- [Finality Providers](finality-provider/README.md)
- [Covenant Committee](https://github.com/babylonlabs-io/covenant-emulator/blob/main/README.md)
