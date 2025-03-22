# Wallet Integration of the Babylon Chain

The Babylon PoS blockchain is built using the Cosmos SDK
and utilises most of the vanilla Cosmos SDK functionality
shared among chains developed using it. Therefore,
a wallet already supporting chains built using
Cosmos SDK should find it straightforward to add
Babylon as a supported blockchain.

In this document will walk through the considerations of integrating
the Babylon blockchain into your wallet:
* [Babylon Genesis Mainnet network information](#babylon-genesis-mainnet-network-information)
* [Accounts, message signing, token balance, and token transfer](#accounts-message-signing-token-balance-and-token-transfer)
* [Staking](#staking)
* [Unbonding](#unbonding)

### Babylon Genesis Mainnet Network Information

Following is a list of the key network details of
the Babylon Genesis Mainnet (`baby_3535-1`):
* RPC nodes can be found [here](../../README.md)
* Chain ID: `baby_3535-1`
* Bech32 Configuration can be found
  [here](https://github.com/babylonlabs-io/babylon/blob/release/v1.x/app/params/config.go#L35)
* Token minimum denomination: `ubbn` (6 decimals)
* Human-readable denomination: `BABY`

### Accounts, message signing, token balance, and token transfer

The Babylon PoS chain utilises the default Cosmos SDK
functionality for accounts, message signing,
token balance, and token transfer.
Please refer to the relevant Cosmos SDK documentation
for more details.

### Staking

The Babylon blockchain uses an epochised staking
mechanism where staking transactions are executed
at the end of an epoch rather than immediately.
* An epoch is defined as a specific block range,
  determined by an epoch interval defined
  in the `x/epoching` module's
  [parameters](https://github.com/babylonlabs-io/babylon/blob/release/v1.x/proto/babylon/epoching/v1/params.proto).
* During each epoch, staking messages are queued
  in a delayed execution queue.
* At the epoch's end, all queued staking messages
  are processed in a batch, resulting in
  epoch based voting power transitions.

To enable this mechanism,
Babylon modifies the standard Cosmos SDK staking process:
* Babylon replaces the default Cosmos SDK `x/staking` module
  with a custom module, `x/epoching`.
* This custom module wraps the standard staking functionality
  to enforce epoch-based voting power transitions.
* The wrapped staking messages are largely similar
  to those in the default `x/staking` module.
  The specifications of these wrapped messages are available
  [here](https://github.com/babylonlabs-io/babylon/tree/main/x/epoching).

Wallets wishing to support Babylon PoS delegations
natively must use the custom `x/epoching` mechanism.

The epochised staking approach introduces the following
UX considerations for wallet integration:
* **Delayed Staking Activation**: Although wrapped staking messages are
  executed immediately, the actual staking operation takes effect only
  at the epoch's end. Wallets should clearly communicate this
  delay to users to set proper expectations.
* **Delayed Funds Locking**: Users' funds remain liquid until staking
  activation occurs at the epoch's conclusion. This creates a for staking failure:
  if users transfer or spend their funds before staking takes effect,
  the staking transaction will fail.
  Wallets should warn users about this possibility.

The above mechanism presents the following UX considerations
that wallets should take into account:
* Delayed staking activation: While the wrapped staking message is executed
  immediately, the staking operation happens at the end of the epoch.
  Wallets should indicate to the user that their staking will not take
  into effect immediately.
* Delayed funds locking: Due to the delayed staking activation, the user's
  funds remain liquid until the staking takes into effect. This might
  lead users to transfer them or spend them in some way, leading
  to the staking transaction failing at the end of the epoch.

Wallets can provide users with visibility into pending staking
messages using the
[LastEpochMsgs query in x/epoching](https://github.com/babylonlabs-io/babylon/blob/main/proto/babylon/epoching/v1/query.proto#L46).
This query allows wallets to display the messages queued
for execution at the end of the current epoch.

### Unbonding

Babylon speeds up the unbonding process by leveraging
Bitcoin timestamping, significantly reducing
the unbonding period from the default 21 days in the
Cosmos SDK to approximately 16-17 hours.

This process works as follows:
* **Epoch Timestamping**: At the end of each epoch,
  Babylon records its blockchain state onto the
  Bitcoin blockchain through a Bitcoin timestamp.
* **Bitcoin Confirmations**: Once the timestamp receives
  a sufficient number of confirmations on the Bitcoin blockchain
  (a parameter configurable in Babylon), the state of the epoch
  if considered finalized.
  * The number of required Bitcoin confirmations is set by the
    `x/btccheckpoint` module, detailed
    [here](https://github.com/babylonlabs-io/babylon/blob/main/proto/babylon/btccheckpoint/v1/params.proto#L24)
  * On the Babylon Genesis mainnet, this value will be set to 100 confirmations,
    corresponding to roughly 16-17 hours for unbonding to be completed,
    assuming an average Bitcoin block time of 10 minutes.
* **Unbonding Finalization**: All unbonding requests submitted
  up to the end of that epoch are processed and finalized
  after the required Bitcoin confirmations are reached.

An example scenario demonstrating how fast unbonding
works in practice:
* **Setup**
  * Epoch interval: 100 blocks
  * Bitcoin confirmations for finalization: 100 blocks
* **Unbonding Request**:
  * A user submits an unbonding transaction at block `157`
* **Epoch Processing**:
  * The unbonding transaction is queued and processed at
    the end of the epoch (block 200).
  * The user’s status is updated to unbonding, and the epoch’s
    state is timestamped on Bitcoin.
* **Finalization**:
  * After ~16-17 hours, the Bitcoin timestamp reaches 100 confirmations.
  * Babylon detects this and completes the unbonding process,
    fully unbonds the user’s stake.
