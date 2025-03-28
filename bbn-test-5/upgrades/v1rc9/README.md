# `v1rc9` Software Upgrade

## Upgrade overview

- **Upgrade version**: `v1.0.0-rc.9`
- **Upgrade height**: `619500`
- **Upgrade overview**: This upgrade fixes the `Resume Finality` Babylon node
  handler. For a detailed changelog, visit the [release note](https://github.com/babylonlabs-io/babylon/releases/tag/v1.0.0-rc.9).

## Upgrade process

### Prepare the upgrade binary

- Obtain the `v1.0.0-rc.9` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases page](https://github.com/babylonlabs-io/babylon/releases/tag/v1.0.0-rc.9)
  - Build the binary in your machine:

    ```shell
    git checkout v1.0.0-rc.9
    BABYLON_BUILD_OPTIONS="testnet" make install
    ```

  - If you’re working with Docker images, you can pull the pre-built Docker image:

    ```shell
    docker pull babylonlabs/babylond:v1.0.0-rc.9-testnet
    ```

### Perform the upgrade

To upgrade your Babylon node at the upgrade height, please perform the following steps:

- Stop your Babylon node
- Swap your babylon binary with the prepared `v1.0.0-rc.9` binary
- Start your Babylon node
