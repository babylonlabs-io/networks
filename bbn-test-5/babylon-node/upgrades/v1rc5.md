# `v1rc5` Software Upgrade

## Upgrade overview

- **Upgrade version**: `v1.0.0-rc.5`
- **Upgrade height**: `326120`
- **Upgrade overview**: This upgrade introduces major changes to BLS key management,
  to improve operational experience and enable usage of remote and threshold
  signing.

## Technical deep-dive

Babylon version `v1.0.0-rc.5` introduces major changes related to BLS key
management.

Until now, every CometBFT Validator had to manually generate a BLS key, which is
used to sign the last Babylon block of each Babylon epoch and enable the BTC
Timestamping protocol. The BLS key was stored alongside the validator signing
key in the `priv_validator_key.json` file. This design decision led to a setup
that was prone to operational errors and made the use of remote / threshold
signers impossible.

With this upgrade, the BLS key is now separated from the Validator signing key
(`priv_validator_key.json`) and stored on a separate, password-protected file
named `bls_key.json`.  The BLS key is encrypted using
[ERC-2335](https://eips.ethereum.org/EIPS/eip-2335) and the
encryption password is located in a txt file named `bls_password.txt`. The
existence of the BLS key is verified during node startup, with the node unable
to start unless the BLS key exists.

This means that all existing testnet Babylon validator/node operators will need
to setup their BLS files:

- **CometBFT Validators** will have to migrate their BLS keys outside of the
  `priv_validator_key.json` file.
  - With the removal of the BLS key from your CometBFT keys file, you can now
    use remote signing software to operate your Validator (
    [TMKMS](https://github.com/iqlusioninc/tmkms),
    [horcrux](https://github.com/strangelove-ventures/horcrux))!
- **Node operators without BLS keys** will have to set up a BLS key, similar to
  being required to have a `priv_validator_key.json`.

In the future, when you initialize a node from scratch its BLS key will be
auto-generated through the babylond init command.

## Upgrade process

### Prepare the upgrade binary

- Obtain the `v1.0.0-rc.5` binary. You can achieve this in multiple ways:
  - Download the binary from the [releases page](https://github.com/babylonlabs-io/babylon/releases/tag/v1.0.0-rc.5)
  - Build the binary on your machine
    ```shell
    git checkout v1.0.0-rc.5
    BABYLON_BUILD_OPTIONS="testnet" make install
    ```
  - If you’re working with Docker images, you can pull the pre-built Docker image:
    ```shell
    docker pull babylonlabs/babylond:v1.0.0-rc.5-testnet
    ```
### Perform the upgrade

- Stop your Babylon node
- Swap your babylon binary with the prepared `v1.0.0-rc.5` binary
- **If you are a CometBFT Validator**: Migrate your BLS key away from your
  Validator’s private key
  - Backup the `$HOME/config/priv_validator_key.json` file before the migration.
  - Verify that the `$HOME/config/priv_validator_key.json` contains the
    Validator singing key and a BLS key.
  - Execute the command `babylond migrate-bls-key` to separate your BLS key and
    store it in  `$HOME/config/bls_key.json`. You will be asked to insert a
    password to encrypt the BLS key, which will be automatically saved in
    `$HOME/config/bls_password.txt`.
  - Verify that `$HOME/config/bls_key.json` and `$HOME/config/bls_password.txt`
    files exist
  - Verify that $HOME/config/priv_validator_key.json now only contains the
    CometBFT signing key
- **If you are not a CometBFT Validator**: Create a BLS key
  - Execute the command `babylond create-bls-key` to generate a BLS key for your
    node. You will be asked to insert a password to encrypt the BLS key, which
    will be automatically saved in a file named `$HOME/config/bls_password.txt`.
    Your BLS key will be saved in a file named `$HOME/config/bls_key.json`.
  - Verify that `$HOME/config/bls_key.json` and `$HOME/config/bls_password.txt`
    files exist
- Start your Babylon node
