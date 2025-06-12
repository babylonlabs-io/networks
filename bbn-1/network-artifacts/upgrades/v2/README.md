# `v2` Software Upgrade

## Upgrade overview

- **Upgrade version**: `v2.0.0`
- **Upgrade height**: `596369`

## Upgrade process

### Prepare the upgrade binary

Obtain the `v2.0.0` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases
    page](https://github.com/babylonlabs-io/babylon/releases/tag/v2.0.0)
  - Build the binary on your machine
    ```shell
    git checkout v2.0.0
    make install
    ```
  - If you’re working with Docker images, you can pull the pre-built Docker image:
    ```shell
    docker pull babylonlabs/babylond:v2.0.0
    ```

### Perform the upgrade

Perform the following steps to upgrade your Babylon node:
* Stop your Babylon node
* Swap your babylon binary with the prepared `v2.0.0` binary
  * Please remove `--x-crisis-skip-assert-invariants` babylond flag from your
    node startup command. The `x/crisis` module has been removed in this
    release.
* Start your Babylon node
