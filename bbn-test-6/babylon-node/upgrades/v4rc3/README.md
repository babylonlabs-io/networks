# `v4rc3` Software Upgrade

## Upgrade overview

- **Upgrade version**: `v4.0.0-rc.3`
- **Upgrade height**: `205840`

## Upgrade process

### Prepare the upgrade binary

Obtain the `v4.0.0-rc.3` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases
    page](https://github.com/babylonlabs-io/babylon/releases/tag/v4.0.0-rc.3)
  - Build the binary on your machine
    ```shell
    git checkout v4.0.0-rc.3
    BABYLON_BUILD_OPTIONS="testnet" make install
    ```
  - If you're working with Docker images, you can pull the pre-built Docker image:
    ```shell
    docker pull babylonlabs/babylond:v4.0.0-rc.3-testnet
    ```

### Perform the upgrade

Perform the following steps to upgrade your Babylon node:
* Stop your Babylon node
* Swap your babylon binary with the prepared `v4.0.0-rc.3` binary
* Start your Babylon node
