# Covenant Committee

The Covenant Emulation committee comprises of entities operating a covenant
signer to sign on-demand unbonding and slashing transactions.
The committee has 9 seats, which are filled by the following entities:
* Babylon Labs: 3 seats
* CoinSummer Labs: 1 seat
* RockX: 1 seat
* AltLayer: 1 seat
* Zellic: 1 seat
* Informal Systems: 1 seat
* Cubist: 1 seat

The covenant emulation committee operates on all phases of the Babylon mainnet
launch, and during the transitionary stage between Phase-1 and Phase-2
will operate separate programs for each stage to support both Phase-1 and
Phase-2 stakers.
Below, we detail the specifics of the operation for each phase.

## Phase-2

During Phase-2, the covenant emulation committee is responsible for operationg
the [covenant-emulator](https://github.com/babylonlabs-io/covenant-emulator),
a daemon responsible for connecting with a Babylon Genesis node and monitoring
for staking registrations that are pending verification. Once such a staking
transaction is identified, the covenant emulator daemon submits signatures for
the on-demand unbonding, slashing, and unbonding slashing transactions.

> **Note**: The Babylon Genesis chain involves slashing of finality providers
> for double signing offences. This means that in Phase-2, covenant committee
> members submit not only unbonding signatures, but slashing signatures as
> well.

The latest list of covenant public keys and operating entities can be found
[here](./covenant-committee.json).

> **Important**: The above list might be outdated. The best source of truth on the
> current covenant committee members and their keys is the Babylon
> Genesis node parameters. You should aim to retrieve the parameters from
> there.

## Phase-1

During Phase-1, the covenant emulation committee is responsible for operating
the [covenant signer](https://github.com/babylonlabs-io/covenant-signer),
a daemon accepting requests for signing on-demand unbonding transactions.

The Covenant Emulation Committee has 9 members, 3 of which
are operated by Babylon Labs. The Covenant quorum configuration as
well as the current members can be found in the
[staking parameters](../parameters/global-params.json).

A full list of the endpoints and the corresponding Covenant BTC Public Keys
for the phase-1 covenant committee follows below, grouped by the operating entity.

> **Note**: Use this list only for on-demand unbonding of Phase-1 stakes,
> i.e., stakes that have not been registered to the Babylon Genesis node.
> On-demand unbonding of stakes registered on Babylon Genesis
> follows a different procedure which is documented
> [here](https://github.com/babylonlabs-io/babylon/blob/release/v1.x/docs/register-bitcoin-stake.md#41-on-demand-unbonding).

* Babylon Labs
  * Signer 0
    * key: `03d45c70d28f169e1f0c7f4a78e2bc73497afe585b70aa897955989068f3350aaa`
    * URL: https://covenant-signer0.babylonlabs.io
  * Signer 1
    * key: `034b15848e495a3a62283daaadb3f458a00859fe48e321f0121ebabbdd6698f9fa`
    * URL: https://covenant-signer1.babylonlabs.io
  * Signer 2
    * key: `0223b29f89b45f4af41588dcaf0ca572ada32872a88224f311373917f1b37d08d1`
    * URL: https://covenant-signer2.babylonlabs.io
* CoinSummer Labs
  * key: `02d3c79b99ac4d265c2f97ac11e3232c07a598b020cf56c6f055472c893c0967ae`
  * URL: https://babylon-covenant-signer.coinsummer.com
* RockX
  * key: `03f178fcce82f95c524b53b077e6180bd2d779a9057fdff4255a0af95af918cee0`
  * URL: https://babylon-mainnet-covenant-signer.rockx.com
* AltLayer
  * key: `038242640732773249312c47ca7bdb50ca79f15f2ecc32b9c83ceebba44fb74df7`
  * URL: https://babylon-mainnet-covenant-signer.alt.technology
* Zellic
  * key: `03cbdd028cfe32c1c1f2d84bfec71e19f92df509bba7b8ad31ca6c1a134fe09204`
  * URL: https://babylon-mainnet-covenant-signer.zellic.net
* Informal Systems
  * key: `03e36200aaa8dce9453567bba108bdc51f7f1174b97a65e4dc4402fc5de779d41c`
  * URL: https://covenant-signer-babylon.informalsystems.io
* Cubist
  * key: `03de13fc96ea6899acbdc5db3afaa683f62fe35b60ff6eb723dad28a11d2b12f8c`
  * URL: https://bbn-mainnet-covsign.cubestake.xyz
