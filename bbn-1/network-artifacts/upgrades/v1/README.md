# `v1` Software Upgrade

## Upgrade overview

- **Upgrade version**: `v1.0.0`
- **Upgrade height**: `226`

## Upgrade process

### Prepare the upgrade binary

Obtain the `v1.0.0` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases page](https://github.com/babylonlabs-io/babylon/releases/tag/v1.0.0)
  - Build the binary on your machine
    ```shell
    git checkout v1.0.0
    BABYLON_BUILD_OPTIONS="mainnet" make install
    ```
  - If you’re working with Docker images, you can pull the pre-built Docker image:
    ```shell
    docker pull babylonlabs/babylond:v1.0.0
    ```

### Perform the upgrade

Perform the following steps to upgrade your Babylon node:
- Stop your Babylon node
- Swap your babylon binary with the prepared `v1.0.0` binary
- **If you are a CometBFT Validator**: Separate your BLS key from your Validator’s
  private key
  - Backup the `$HOME/config/priv_validator_key.json` file before the migration.
  - Verify that the `$HOME/config/priv_validator_key.json` contains the
    Validator signing key and a BLS key.
  - Execute the command `babylond migrate-bls-key` to separate your BLS key and
    store it in  `$HOME/config/bls_key.json`. You will be asked to insert a
    password to encrypt the BLS key, which will be automatically saved in
    `$HOME/config/bls_password.txt`. Alternatively, if you prefer not to store
    the password on disk, you can set the environment variable
    `BABYLON_BLS_PASSWORD` equal to the BLS key password prior to executing
    the migration command.
  - Verify that `$HOME/config/bls_key.json` and `$HOME/config/bls_password.txt`
    files exist
  - Verify that $HOME/config/priv_validator_key.json now only contains the
    CometBFT signing key
- **If you are not a CometBFT Validator**: Create a BLS key
  - Execute the command `babylond create-bls-key` to generate a BLS key for your
    node. You will be asked to insert a password to encrypt the BLS key, which
    will be automatically saved in a file named `$HOME/config/bls_password.txt`.
    Your BLS key will be saved in a file named `$HOME/config/bls_key.json`.
    Alternatively, if you prefer not to store the password on disk, you can set
    the environment variable `BABYLON_BLS_PASSWORD` equal to the BLS key
    password prior to executing the creation command.
  - Verify that `$HOME/config/bls_key.json` and `$HOME/config/bls_password.txt`
    files exist
- Start your Babylon node
