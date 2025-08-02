# `v2.0.0-rc.0` Software Upgrade

This document summarizes the procedure to upgrade a Babylon Finality Provider
to version v2.0.0-rc.0.

## Table of Contents

1. [High-level Overview](#1-high-level-overview)
2. [Technical Deep-dive](#2-technical-deep-dive)
3. [Applying the upgrade](#3-applying-the-upgrade)
   1. [Preparation](#31-preparation)
   2. [Execution](#32-execution)
   3. [Verification](#33-verification)

## 1. High-level Overview

- **Upgrade version**: `v2.0.0-rc.0`
- **Upgrade Babylon height**: `X` (TODO: specify the height)
- **Upgrade overview**: This upgrade introduces a major refactoring that
  transforms the Finality Provider into a reusable SDK, to enable the
  development of Finality Provider software for BSNs.
- **Finality Providers who should participate**: Only Babylon Finality Providers.

## 2. Technical Deep-dive

The Babylon Genesis Testnet `v3.0.0-rc.0` upgrade (TODO: link to corresponding
upgrade doc) is coupled with a coordinated breaking upgrade of the Finality
Provider software from `v1.x.x` (`v1.0.0`, `v1.1.0-rc.0`, `v1.1.0-rc.1`) to
`v2.0.0-rc.0`.

Finality Provider `v2.0.0-rc.0` introduces a major refactoring of the codebase
into a reusable SDK. This aims to enable the development of Finality
Provider software for Bitcoin Supercharged Networks (BSNs). The following BSN
stacks are initially supported:
- Ethereum L2 Rollup BSNs, integrating via the deployment of a CosmWasm Smart
  Contract on the Babylon Genesis Testnet. The Rollup BSN Finality Provider
  will be responsible for the submission of finality signatures and public
  randomness to the Contract.
- Cosmos SDK BSNs, integrating via the deployment of a CosmWasm Smart Contract
  on their respective chains and the establishment of IBC Channels with Babylon.
  The Cosmos BSN Finality Provider will be responsible for the submission of
  finality signature and public randomness to the Contract.

**It's important to emphasize that the BSN Finality Provider software will be
distinct from the Babylon Finality Provider software, coming with dedicated
binaries and operational guides. Babylon Finality Providers will continue
operating the original software.**

*BSN Finality Providers will not participate in this software upgrade, as they
will start operating their software only after the Babylon Genesis Testnet
is upgraded to the `v3.0.0-rc.0` version.*

## 3. Applying the upgrade

### 3.1. Preparation

The following actions must be taken prior to the upgrade time:
- Ensure that your Babylon Finality Provider and EOTS daemons are currently
  operating version `v1.0.0`, `v1.1.0-rc.0` or `v1.1.0-rc.1`.
- Obtain the `v2.0.0-rc.0` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases
    page](https://github.com/babylonlabs-io/finality-provider/releases/tag/v2.0.0-rc.0).
  - Build the binary on your machine:
    ```shell
    git checkout v2.0.0-rc.0
    make install
    ```
  - Pull the pre-built Docker image:
    ```shell
    docker pull babylonlabs/finality-provider:v2.0.0-rc.0
    ```
- Prepare for the Babylon `v3.0.0-rc.0` node upgrade following the instructions
  here (TODO: Point to the Babylon node upgrade guide).

Once the above are completed, patiently wait for the Babylon Genesis Testnet
to reach the upgrade height `X` (TODO: Specify the height).

### 3.2. Execution

The Babylon Finality Provider and EOTS daemon upgrades are tightly coupled
with the Babylon network software upgrade. The following steps must be executed
with precise ordering and timing, to ensure minimum downtime and no slashing
risk for your Finality Provider:
- Once the Babylon upgrade height `X` (TODO: Specify the height) is reached,
  stop your Babylon Finality Provider and EOTS daemons.
- Upgrade your Babylon node to `v3.0.0-rc.0` following the instructions here
  (TODO: Point to the Babylon node upgrade guide)
- Swap the Babylon Finality Provider and EOTS daemon binaries with the latest
  ones.
- In your Babylon Finality Provider config, append the following configuration
  to the `[Application Options]` section (TODO: Specify the height):
  ```shell
    ; The height at which the context signing will start
    ContextSigningHeight = X
  ```
- Start the EOTS daemon. **DO NOT START THE BABYLON FINALITY PROVIDER DAEMON YET.**
- Wait until the Babylon produces block `X + 1`. This can take up to 5 minutes,
  depending on how fast Babylon CometBFT Validators upgrade their Babylon nodes.
- Once the block is produced, start your Babylon Finality Provider daemon.

### 3.3. Verification

After completing the [execution](#32-execution) section, perform the following
verifications to ensure that your Babylon Finality Provider was upgraded
successfully and is functioning as expected:
- Verify that your Babylon Finality Provider has voted for block `X` (TODO:
  Specify the height). You can achieve this in many ways:
  - Query the Babylon node directly, replacing `FP_BTC_PK_HEX` with the BTC
    public key of your Babylon Finality Provider in hex format. The resulting
    height should be equal or greater to `X` (TODO: Specify the height).
    ```shell
    babylond q btcstaking finality-provider \
      FP_BTC_PK_HEX \
      --node https://babylon-testnet-rpc.polkachu.com:443 -o json \
      | jq -r .finality_provider.highest_voted_height
    ```
  - Check your Babylon Finality Provider logs, and look for a log of the
    following format:
    ```shell
    LOG_TIMESTAMP	info	successfully submitted the finality signature to the consumer chain	{"consumer_id": "bbn-test-5", "pk": "FP_BTC_PK_HEX", "start_height": X, "end_height": X, "tx_hash": "TX_HASH"}
    ```
  - A network explorer can also be consulted (examples:
   [Xangle](https://babylon-explorer.xangle.io/testnet/finality-providers),
   [Nodes.guru](https://testnet.babylon.explorers.guru/finality-providers),
   [Mintscan](https://www.mintscan.io/babylon-testnet/finality-providers)).
   Explorers have a data indexing overhead, so it's likely that your finality
   signatures will be reflected after ~1 minute.

- Verify that your Babylon Finality Provider is not in `Slashed` state. You
  can achieve this in many ways:
  - Query the Babylon node directly, replacing `FP_BTC_PK_HEX` with the BTC
    public key of your Babylon Finality Provider in hex format. The result
    should be `0`.
    ```shell
    babylond q btcstaking finality-provider \
      FP_BTC_PK_HEX \
      --node https://babylon-testnet-rpc.polkachu.com:443 -o json \
      | jq -r .finality_provider.slashed_babylon_height
    ```
  - A network explorer can also be consulted (examples:
   [Xangle](https://babylon-explorer.xangle.io/testnet/finality-providers),
   [Nodes.guru](https://testnet.babylon.explorers.guru/finality-providers),
   [Mintscan](https://www.mintscan.io/babylon-testnet/finality-providers)).
   Explorers have a data indexing overhead, so it's likely that your finality
   signatures will be reflected after ~1 minute.
