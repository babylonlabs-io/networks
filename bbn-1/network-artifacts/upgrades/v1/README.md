# `v1` Software Upgrade

## Upgrade overview

- **Upgrade version**: `v1.0.1`
- **Upgrade height**: `226`

## Upgrade process

### Prepare the upgrade binary

Obtain the `v1.0.1` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases
    page](https://github.com/babylonlabs-io/babylon/releases/tag/v1.0.1)
  - Build the binary on your machine
    ```shell
    git checkout v1.0.1
    make install
    ```
  - If you’re working with Docker images, you can pull the pre-built Docker image:
    ```shell
    docker pull babylonlabs/babylond:v1.0.1
    ```

### Perform the upgrade

Perform the following steps to upgrade your Babylon node:
- Stop your Babylon node
- Swap your babylon binary with the prepared `v1.0.1` binary
- **If you are a CometBFT Validator**: Separate your BLS key from your Validator’s
  private key
  - Backup the `$HOME/config/priv_validator_key.json` file before the migration.
  - Verify that the `$HOME/config/priv_validator_key.json` contains the
    Validator signing key and a BLS key.
  - Execute the command `babylond migrate-bls-key` to separate your BLS key and
    store it in  `$HOME/config/bls_key.json`. You will be asked to insert a
    password to encrypt the BLS key, please see the [BLS key password
    options](#setting-the-bls-key-password) section below for more details on your
    available options.
  - Verify that the `$HOME/config/bls_key.json` file exists. Additionally,
    if you decided to store your BLS password in a text file, verify it exists
    as well.
  - Verify that $HOME/config/priv_validator_key.json now only contains the
    CometBFT signing key
- **If you are not a CometBFT Validator**: Create a BLS key
  - Execute the command `babylond create-bls-key` to generate a BLS key for your
    node. You will be asked to einsert a password to encrypt the BLS key,
    please see the [BLS key password options](#setting-the-bls-key-password)
    section below for more details on your available options.
  - Verify that the `$HOME/config/bls_key.json` file exists. Additionally,
    if you decided to store your BLS password in a text file, verify it exists
    as well.
- Start your Babylon node

### Setting the BLS Key Password

Both the `migrate-bls-key` and `create-bls-key` commands will need to create
and encrypt your BLS key with a password. You have the
following options for specifying your password,
ordered by priority (i.e., if one of the options higher in the list is set,
the subsequent options won't be attempted):
1. The environment variable `BABYLON_BLS_PASSWORD` is set.
2. One of the following CLI options has been set (note that they can't be
   used concurrently)
   1. `--no-bls-key` is a flag that if set designates that an empty BLS
      password should be used.
   2. `--insecure-bls-password=<pass>` allows to specify the BLS password
      as a CLI argument.
   3. `--bls-password-file=<path>` allows to specify a file location that
      contains the plaintext BLS password.
3. (**Recommended**) If none of the above is set, a prompt appears to
   the user to enter their password.
