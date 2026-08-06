# `v4.4` Software Upgrade

## Upgrade overview

- **Upgrade version**: `v4.4.0`
- **Upgrade height**: `2613009`

## Upgrade process

### Prepare the upgrade binary

Obtain the `v4.4.0` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases
    page](https://github.com/babylonlabs-io/babylon/releases/tag/v4.4.0)
  - Build the binary on your machine
    ```shell
    git checkout v4.4.0
    BABYLON_BUILD_OPTIONS="testnet" make install
    ```
  - If you're working with Docker images, you can pull the pre-built Docker image:
    ```shell
    docker pull babylonlabs/babylond:v4.4.0-testnet
    ```

### Perform the upgrade

Perform the following steps to upgrade your Babylon node:
* Stop your Babylon node
* Swap your babylon binary with the prepared `v4.4.0` binary
* Start your Babylon node
