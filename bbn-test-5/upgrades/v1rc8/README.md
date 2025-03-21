# `v1rc8` Software Upgrade

## Upgrade overview

- **Upgrade version**: `v1.0.0-rc.8`
- **Upgrade height**: `589080`

## Upgrade process

To upgrade your Babylon node, please perform the following steps:

- Stop your Babylon node
- Obtain the `v1.0.0-rc.8` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases page](https://github.com/babylonlabs-io/babylon/releases/tag/v1.0.0-rc.8)
  - Build the binary on your machine

    ```shell
    git checkout v1.0.0-rc.8
    BABYLON_BUILD_OPTIONS="testnet" make install
    ```

  - If you’re working with Docker images, you can pull the pre-built Docker image:

    ```shell
    docker pull babylonlabs/babylond:v1.0.0-rc.8-testnet
    ```

- Start your Babylon node
