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
* Stop your Babylon node
* Swap your babylon binary with the prepared `v1.0.1` binary
* **If you are not a CometBFT Validator**: Create a BLS key
  * **Note**: You should not be a validator at the time of this upgrade
    (Babylon Genesis height `226`) as at that point there was only one
    validator in the chain.
  * Execute the command `babylond create-bls-key` to generate a BLS key for your
    node. You will be asked to insert a password to encrypt the BLS key.
    You can specify your BLS password using the following options:
    * **CLI or Environment Variable**: You can specify your password through the
      CLI or an environment variable (note that if both are used concurrently, an
      error will be raised):
      * **Environment Variable**: `BABYLON_BLS_PASSWORD` is set.
      * **CLI flags**: One of the following CLI options has been set:
        * `--no-bls-key` is a flag that if set designates that an empty BLS
          password should be used.
        * `--bls-password-file=<path>` allows to specify a file location that
          contains the plaintext BLS password.
    * **Password Prompt**
      If none of the above is set, a prompt will appear asking you to type your
      password.
  * Verify that the `$HOME/config/bls_key.json` file exists. Additionally,
    if you decided to store your BLS password in a text file, verify it exists
    as well.
* **If you already have a BLS key**: You should not have a BLS key included in
  your node at the time of this upgrade. Please back-up your BLS key (if you
  intend to keep it) and restart the process without setting a BLS key for your
  node prior to applying this upgrade. If you intend to become a validator, you
  can create your BLS key immediatelly after the upgrade.
* Start your Babylon node
