# `v2rc1` Software Upgrade

## Upgrade overview

- **Upgrade version**: `v2rc1`
- **Upgrade height**: `1157475`

## Upgrade process

### Prepare the upgrade binary

Obtain the `v2rc1` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases
    page](https://github.com/babylonlabs-io/babylon/releases/tag/v2.0.0-rc.1)
  - Build the binary on your machine
    ```shell
    git checkout v2.0.0-rc.1
    BABYLON_BUILD_OPTIONS="testnet" make install
    ```
  - If you’re working with Docker images, you can pull the pre-built Docker image:
    ```shell
    docker pull babylonlabs/babylond:v2.0.0-rc.1-testnet
    ```

### Perform the upgrade

Perform the following steps to upgrade your Babylon node:
* Stop your Babylon node
* Swap your babylon binary with the prepared `v2.0.0-rc.1` binary
* Start your Babylon node
