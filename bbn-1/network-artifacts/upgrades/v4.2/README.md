# `v4.2` Software Upgrade

## Upgrade overview

- **Upgrade version**: `v4.2.2`
- **Upgrade height**: `2072934`

## Upgrade process

### Prepare the upgrade binary

Obtain the `v4.2.2` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases
    page](https://github.com/babylonlabs-io/babylon/releases/tag/v4.2.2)
  - Build the binary on your machine
    ```shell
    git checkout v4.2.2
    make install
    ```
  - If you're working with Docker images, you can pull the pre-built Docker image:
    ```shell
    docker pull babylonlabs/babylond:v4.2.2
    ```

### Perform the upgrade

Perform the following steps to upgrade your Babylon node:
* Stop your Babylon node
* Swap your babylon binary with the prepared `v4.2.2` binary
* Start your Babylon node
