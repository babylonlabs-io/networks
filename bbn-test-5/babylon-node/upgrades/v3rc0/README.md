# `v3rc0` Software Upgrade

This document summarizes the procedure to upgrade a Babylon node to version
`v3.0.0-rc.0`.

## Table of Contents

1. [Overview](#1-overview)
2. [Applying the upgrade](#2-applying-the-upgrade)
   1. [Preparation](#21-preparation)
   2. [Execution](#22-execution)
   3. [Verification](#23-verification)

## 1. Overview

- **Upgrade version**: `v3rc0`
- **Upgrade height**: `1692200`

## 2. Applying the upgrade

### 2.1. Preparation

Obtain the `v3rc0` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases
    page](https://github.com/babylonlabs-io/babylon/releases/tag/v3.0.0-rc.0)
  - Build the binary on your machine
    ```shell
    git checkout v3.0.0-rc.0
    BABYLON_BUILD_OPTIONS="testnet" make install
    ```
  - Pull the pre-built Docker image:
    ```shell
    docker pull babylonlabs/babylond:v3.0.0-rc.0-testnet
    ```

### Perform the upgrade

Perform the following steps to upgrade your Babylon node:
1. Stop your Babylon node
2. Swap your babylon binary with the prepared `v3.0.0-rc.0` binary
3. Start your Babylon node
