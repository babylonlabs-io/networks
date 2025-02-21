# Babylon Phase 3 Devenet (Euphrates 0.5.0)

The Phase 3 Devenet is a development network of Babylon Genesis Chain. It implements the full funcationality of Bitcoin staking and allow BSNs to be connected. 

## Network Parameters

### Chain ID

`euphrates-0.5.0`

### Sync from scratch

To boot a node and sync from scratch, Babylon version `euphrates-0.5.0-rc.0` should be used
([reference](https://github.com/babylonlabs-io/babylon/releases/tag/euphrates-0.5.0-rc.0)).

### Seed nodes

Seed nodes can be retrieved from [here](./seeds.txt).

### Peers

Peers can be retrieved from [here](./peers.txt).

### Endpoints

1. RPC

- https://rpc-euphrates.devnet.babylonlabs.io:443

2. LCD (node API)

- https://lcd-euphrates.devnet.babylonlabs.io:443

3. gRPC

- https://grpc-euphrates.devnet.babylonchain.io

### Covenant Committee

The covenant committee consists of 5 signing keys with a quorum being achieved
with 3 signatures. Below are the members of the covenant committee and the
BTC public keys associated with them.

* Babylon Labs:
    * ffeaec52a9b407b355ef6967a7ffc15fd6c3fe07de2844d61550475e7a5233e5
    * a5c60c2188e833d39d0fa798ab3f69aa12ed3dd2f3bad659effa252782de3c31
    * 59d3532148a597a2d05c0395bf5f7176044b1cd312f37701a9b4d0aad70bc5a4
    * 57349e985e742d5131e1e2b227b5170f6350ac2e2feb72254fcc25b3cee21a18
    * c8ccb03c379e452f10c81232b41a1ca8b63d0baf8387e57d302c987e5abb8527

Note: There are no external Covenent Committe member in devnet.

## Network Participants

All four types of participants are hosted by Babylon Labs in devenet environment.

- Babylon Node Operators
- Validators
- Finality Providers
- Covenant Committee