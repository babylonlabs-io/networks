# `v2` Software Upgrade

## Upgrade overview

- **Upgrade version**: `v2`
- **Upgrade height**: `252`

## Upgrade process

### Prepare the upgrade binary

Obtain the `v2` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases
    page](https://github.com/babylonlabs-io/babylon/releases/tag/v2)
  - Build the binary on your machine
    ```shell
    git checkout v2.1.0
    BABYLON_BUILD_OPTIONS="testnet" make install
    ```
  - If you're working with Docker images, you can pull the pre-built Docker image:
    ```shell
    docker pull babylonlabs/babylond:v2.1.0-testnet
    ```

### Perform the upgrade

Perform the following steps to upgrade your Babylon node:
* Stop your Babylon node
* Swap your babylon binary with the prepared `v2` binary
* Start your Babylon node
