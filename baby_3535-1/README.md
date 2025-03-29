# Babylon Genesis Network (WIP)

> **⚠️ Warning**: This network specification is still WIP.
> The WIP indication will be removed once the information is ready
> for consumption.

Welcome to the network page for the Babylon Genesis mainnet (`baby_3535-1`).
This is your central hub 
for network participation information, whether you're running a node, 
operating as a validator, providing finality services, or participating 
in the covenant committee.

## Network Parameters

### Chain ID

`baby_3535-1`

### Genesis

<!--TODO(@filippos): Add genesis file --> 
The genesis file can be retrieved from [here](./network-artifacts/genesis.json).

### State snapshot

<!--TODO(@filippos): Update snapshot and height.
    TODO(@konrad): We also need instructions on how someone can sync from
    scratch due to the chain ID change  --> 
A snapshot including state up to height `X` can be retrieved from
[here](./network-artifacts/baby_3535-1.tar.gz).

<!--TODO(@filippos): Verify version --> 
To boot a node with this snapshot, Babylon version `v1.0.0` should be used
([reference](https://github.com/babylonlabs-io/babylon/releases/tag/v1.0.0)).

### Seed nodes

Seed nodes can be retrieved from [here](./seeds.txt).

### Peers

Peers can be retrieved from [here](./peers.txt).

### Endpoints

#### RPC

Pruned:
- https://babylon.nodes.guru/rpc
- https://babylon-rpc.polkachu.com

Archive:
- https://babylon-archive.nodes.guru/rpc
- https://babylon-archive-rpc.polkachu.com

#### LCD (node API)

Pruned:
- https://babylon.nodes.guru/api
- https://babylon-api.polkachu.com

Archive:
- https://babylon-archive.nodes.guru/api
- https://babylon-archive-api.polkachu.com

#### gRPC

Pruned:
- babylon.nodes.guru:443/grpc
- babylon-grpc.polkachu.com:20690

Archive:
- babylon-archive.nodes.guru:443/grpc
- babylon-archive-grpc.polkachu.com:20690

### Covenant Committee

The covenant committee consists of 9 signing keys with a quorum being achieved
with 6 signatures. Below are the members of the covenant committee and the
BTC public keys associated with them.

* Babylon Labs:
  * `d45c70d28f169e1f0c7f4a78e2bc73497afe585b70aa897955989068f3350aaa`
  * `4b15848e495a3a62283daaadb3f458a00859fe48e321f0121ebabbdd6698f9fa`
  * `23b29f89b45f4af41588dcaf0ca572ada32872a88224f311373917f1b37d08d1`
* Cubist
  * `de13fc96ea6899acbdc5db3afaa683f62fe35b60ff6eb723dad28a11d2b12f8c`
* Informal Systems
  * `e36200aaa8dce9453567bba108bdc51f7f1174b97a65e4dc4402fc5de779d41c`
* Zellic
  * `cbdd028cfe32c1c1f2d84bfec71e19f92df509bba7b8ad31ca6c1a134fe09204`
* RockX
  * `f178fcce82f95c524b53b077e6180bd2d779a9057fdff4255a0af95af918cee0`
* AltLayer
  * `8242640732773249312c47ca7bdb50ca79f15f2ecc32b9c83ceebba44fb74df7`
* CoinSummer Labs
  * `d3c79b99ac4d265c2f97ac11e3232c07a598b020cf56c6f055472c893c0967ae`

## Network Participants

There are four types of participants in the Babylon network.
Please see the setup and configuration guides below:

- [Babylon Node Operators](babylon-node/README.md)
- [Validators](babylon-validators/README.md)
- [Finality Providers](https://github.com/babylonlabs-io/finality-provider/blob/main/README.md)
- [Covenant Committee](https://github.com/babylonlabs-io/covenant-emulator/blob/main/README.md)
