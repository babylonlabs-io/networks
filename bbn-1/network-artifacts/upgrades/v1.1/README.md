# `v1.1` Software Upgrade

## Upgrade overview

- **Upgrade version**: `v1.1.0`
- **Upgrade height**: `301450`

## Upgrade process

### Prepare the upgrade binary

Obtain the `v1.1.0` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases
    page](https://github.com/babylonlabs-io/babylon/releases/tag/v1.1.0)
  - Build the binary on your machine
    ```shell
    git checkout v1.1.0
    make install
    ```
  - If you’re working with Docker images, you can pull the pre-built Docker image:
    ```shell
    docker pull babylonlabs/babylond:v1.1.0
    ```

### Perform the upgrade

Perform the following steps to upgrade your Babylon node:
* Stop your Babylon node
* Swap your babylon binary with the prepared `v1.1.0` binary
* Start your Babylon node
