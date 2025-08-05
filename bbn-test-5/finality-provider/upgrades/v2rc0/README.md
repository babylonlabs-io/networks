# `v2.0.0-rc.0` Software Upgrade

This document summarizes the procedure to upgrade a Babylon Genesis Finality
Provider to version `v2.0.0-rc.0`.

## Table of Contents

1. [Overview](#1-overview)
2. [Technical Deep-dive](#2-technical-deep-dive)
3. [Applying the upgrade](#3-applying-the-upgrade)
  1. [Upgrade the Finality Provider](#31-upgrade-the-finality-provider) 
    1. [Preparation](#311-preparation)
    2. [Execution](#312-execution)
    3. [Verification](#313-verification)
  2. [Upgrade the Finality Provider](#32-upgrade-the-babylon-provider) 
    1. [Preparation](#321-preparation)
    2. [Execution](#322-execution)
    3. [Verification](#323-verification)

## 1. Overview

- **Upgrade version**: `v2.0.0-rc.0`
- **Upgrade Babylon height**: `X` (TODO: specify the height)
- **Upgrade overview**:
  - **Compatibility with Babylon Genesis v3**
  - **Usage of a signing context** to combat the usage of existing signatures for
    separate contexts.
  - **Major refactoring** of the finality provider codebase that
    transforms the Finality Provider into a reusable SDK, to enable the
    development of Finality Provider software for BSNs.

## 2. Technical Deep-dive

The Babylon Genesis Testnet `v3.0.0-rc.0`
[upgrade](../../../babylon-node/upgrades/v3/README.md) is coupled with a
coordinated breaking upgrade of the Finality Provider software from `v1.x.x`
(`v1.0.0`, `v1.1.0-rc.0`, `v1.1.0-rc.1`) to `v2.0.0-rc.0`.

The Finality Provider `v2.0.0-rc.0` upgrade introduces the following major
features:
- Compatibility with the Babylon node `v3.0.0-rc.0` version.
- Introduction of the singing context, which is utilized during the submission
  of finality signatures by the Babylon Genesis Finality Providers. This
  guarantees that existing signatures cannot be re-used for other puproses.
  - Signing context starts getting utilized at the height specified in the
    Babylon Genesis Finality Provider configuration file (value
    `ContextSigningHeight`).
  - From the upgrade Babylon height `X` (TODO: Specify the height) and onwards,
    context signing is **required** for finality signatures to be accepted. Finality
    signatures not utilizing context signing will be rejected, and **prevent
    the Babylon Genesis Finality Provider from submitting a valid finality
    signature for that height**. The reason is that each signature utilizes
    a public randomness commitment of a specific height, which can't be re-used.
  - Thus, it's critical that the Babylon Genesis Finality Providers upgrade
    their software and properly configure the context signing height no later
    than the Babylon Genesis Testnet upgrade height `X`. (TODO: Specify the
    upgrade height). **For safety, Finality Provider operators must upgrade
    their software earlier than the Babylon Genesis Testnet network upgrade.**
- Major refactoring of the codebase into a reusable SDK. This aims to enable
  the development of Finality Provider software for Bitcoin Supercharged
  Networks (BSNs). The initial BSN stacks will include Ethereum L2 Rollups and
  Cosmos SDK chains.
  - It's important to emphasize that the BSN Finality Provider software will be
    distinct from the Babylon Finality Provider software, coming with dedicated
    binaries and operational guides. Babylon Finality Providers will continue
    operating the original software.

## 3. Applying the upgrade

Applying the upgrade constitutes of 2 steps:
- Upgrade your Finality Provider and EOTS daemons **before** the Babylon Genesis
  Testnet upgrade height `X` (TODO: Specify the height) is reached.
- Upgrade your Babylon node once the network halts.

### 3.1. Upgrade the Finality Provider

**NOTE: THIS MUST HAPPEN BEFORE THE BABYLON GENESIS TESTNET UPGRADE HEIGHT
`X` IS REACHED!**

#### 3.1.1. Preparation

Follow the steps below:
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

#### 3.1.2. Execution

The upgraded Babylon Genesis Finality Provider and EOTS daemon binaries are
tightly coupled with the Babylon Genesis Testnet software upgrade.

The following steps must be executed **before the Babylon Genesis Testnet
upgrade height is reached**, to ensure that your finality provider does not
experience downtime or submit invalid signatures:
1. **Stop the Finality Provider and EOTS daemons**.
2. **Swap the Babylon Genesis finality provider and EOTS daemon binaries with
   the new ones**.
3. In your Babylon Genesis Finality Provider config, append the following
   configuration to the `[Application Options]` section
   (TODO: Specify the height):
   ```shell
   [Application Options]

   ; The height at which the context signing will start
   ContextSigningHeight = X - 1
   ```
4. **Start the Finality Provider and the EOTS Daemons.**

After these steps are completed, verify your Finality Provider is signing blocks
following the steps [here](#313-verification) and wait until the Babylon Genesis
Testnet upgrade height `X` is reached.

#### 3.1.3. Verification

Verify that your Babylon Finality Provider is voting as expected:
  - Query the Babylon node directly, replacing `FP_BTC_PK_HEX` with the BTC
    public key of your Babylon Finality Provider in hex format. The height
    should be growing
    ```shell
    babylond q btcstaking finality-provider \
      FP_BTC_PK_HEX \
      --node https://babylon-testnet-rpc.polkachu.com:443 -o json \
      | jq -r .finality_provider.highest_voted_height
    ```
  - Check your Babylon Finality Provider logs, and look for logs of the
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

### 3.2. Upgrade the Babylon node

#### 3.2.1. Preparation

Prepare for the Babylon `v3.0.0-rc.0` node upgrade following the instructions
[here](../../../babylon-node/upgrades/v3/README.md#3-1-preparation).

#### 3.2.2. Babylon Node Upgrade

Once the Babylon Genesis Testnet upgrade height `X` is reached, perform the
following steps:
1. **Upgrade your Babylon node to `v3.0.0-rc.0` following the instructions
   [here](../../../babylon-node/upgrades/v3/README.md#3-2-execution).**
2. Wait until the Babylon produces block `X`. This can take up to 5 minutes,
   depending on how fast Babylon CometBFT Validators upgrade their Babylon
   nodes.

#### 3.2.3. Verification

After completing the [execution](#322-execution) section, perform the following
verifications to ensure that your Babylon Finality Provider was upgraded
successfully and is functioning as expected:
- Verify that your Babylon Finality Provider has voted for blocks `X - 1` and
  `X` (TODO: Specify the height). You can achieve this in many ways:
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
