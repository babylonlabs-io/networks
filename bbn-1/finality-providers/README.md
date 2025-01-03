# Phase-2 Finality Provider Registry

- [Phase-1](./phase-1.md)

## Background

Babylon launched Phase-1 with only the generation of the BTC Extractable One
Time Signature (EOTS) keys by the instructions defined in the
[Phase-1 Guide](./phase-1.md). Finality providers will now generate the BABY
keys and a BABY address to receive funds on the beginning of the network
to start signing finality provider messages.

## Steps

These steps takes into consideration that the finality provider already
made the [Registration Steps](./phase-1.md#registration-steps) and has
the binaries available in the machine.

### 1. Install `Babylond`

The babylon daemon is utilized to create the BABY keys. To follow this guide,
please use the
[babylond v1.0.x](https://github.com/babylonlabs-io/babylon/releases/tag/v1.0.0-rc.2)
version.

```bash
$ git clone https://github.com/babylonlabs-io/babylon.git

Cloning into 'babylon'...
```

Checkout to the v0.4.0 release tag

```bash
$ cd babylon
$ git checkout v1.0.0-rc.2

Note: switching to 'v1.0.0-rc.2'.
```

At the root of the babylon repository install the binaries

```bash
$ make install

go install -mod=readonly -tags "netgo ledger mainnet" -ldflags '-X github.com/cosmos/cosmos-sdk/version.Name=babylon -X github.com/cosmos/cosmos-sdk/version.AppName=babylond -X github.com/cosmos/cosmos-sdk/version.Version=backport/fix-gap-unfinalized-6e508e8a2190d23c41c95bf669bc88b3fbb93d09 -X github.com/cosmos/cosmos-sdk/version.Commit=6e508e8a2190d23c41c95bf669bc88b3fbb93d09 -X "github.com/cosmos/cosmos-sdk/version.BuildTags=netgo,ledger" -w -s' -trimpath  ./...
```

Check if the installation succeeded by running `babylond --help`.

```bash
$ babylond --help
Start the Babylon app

Usage:
  babylond [command]

Available Commands:
  add-genesis-account Add a genesis account to genesis.json
  collect-gentxs      Collect genesis txs and output a genesis.json file
  comet               CometBFT subcommands
  config              Utilities for managing application configuration
  create-bls-key      Create a pair of BLS keys for a validator
  debug               Tool for helping with debugging your application
  export              Export state to JSON
  gen-helpers         Useful commands for creating the genesis state
  gentx               Generate a genesis tx carrying a self delegation
  help                Help about any command
  init                Initialize private validator, p2p, genesis, and application configuration files
  keys                Manage your application's keys
  migrate             Migrate genesis to a specified target version
  module-sizes        print sizes of each module in the database
  prepare-genesis     Prepare a genesis file
  query               Querying subcommands
  rollback            rollback Cosmos SDK and CometBFT state by one height
  start               Run the full node
  status              Query remote node for status
  testnet             Initialize files for a babylon testnet
  tx                  Transactions subcommands
  validate-genesis    validates the genesis file at the default location or at the location passed as an arg
  version             Print the application binary version information

Flags:
  -h, --help                help for babylond
      --home string         directory for config and data (default "/home/rafilx/.babylond")
      --log_format string   The logging format (json|plain) (default "plain")
      --log_level string    The logging level (trace|debug|info|warn|error|fatal|panic|disabled or '*:<level>,<key>:<level>') (default "info")
      --log_no_color        Disable colored logs
      --trace               print out full stack trace on errors

Use "babylond [command] --help" for more information about a command.
```

### 2. Create BABY Keys

To create an BABY key pair to receive initial funding by running
`babylond keys add`. This BABY key pair is stored in the
file system and will be used in later steps of the guide.

This command has one parameter `<baby-key-name>` and several flag options:

- `--home` specifies the home directory of the `babylon` in which
the new key will be stored.
- `--passphrase` specifies the password used to encrypt the key, if such a
passphrase is required.
- `--hd-path` is the hd derivation path of the private key.
- `--keyring-backend` specifies the keyring backend, any of
`[file, os, kwallet, test, pass, memory]` are available, by default `test` is
used.
- `--recover` indicates whether the user wants to provide a seed phrase to
recover an existing key instead of creating a new one.

```shell
babylond keys add my-key-name --home /path/to/babylon/home/ --keyring-backend file

Enter keyring passphrase (attempt 1/3):
...

- address: bbn17ew0he6svxrqj2c7mef7qsyg0assc2upa5gy7w
  name: my-key-name
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"A5UjwURAlm0ndhMLfmNKIe4wzc8NnsBkNOgr7Ogx6kQQ"}'
  type: local


**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.

bad mnemonic private split escape wage suit banner affair home fine rent erosion hurry bicycle throw tilt warfare silk rude real frown cabin few
```

> Reminder: if the `--keyring-backend` flag was used to create the key, the
same flag should be used later for accessing this key.

At the end of these steps, the BABY key pair will be generated. The key
pair and the mnemonic generated must be stored in a safe place.

**⚠ Warning!**
Store the **mnemonic** in a safe place. The mnemonic is the only way you can
recover your keys in the case of loss or file system corruption.

### 3. Proof-of-Possesion Export

Registering an address on the Babylon chain to receive funds of an EOTS public
key requires proof-of-possession (pop). The pop proves that the owner of the
EOTS public key want to give out funds to this BABY address. To export the pop
run `eotsd pop-export`

This command has one parameter `<baby-key-address>` and several flag options:

- `--home` specifies the home directory of the `eotsd` in which
the EOTS key previously created in
[Phase-1](./phase-1.md#2-create-eots-keys) was stored.
- `--key-name` flag that identifies the name of the key to sign
the BABY address.
- `--passphrase` specifies the password used to decrypt the key, if such a
passphrase is required.
- `--eots-pk` is the EOTS public key.
- `--keyring-backend` specifies the keyring backend, any of
`[file, os, kwallet, test, pass, memory]` are available, by default `test` is
used.

```shell
$ eotsd pop-export bbn17ew0he6svxrqj2c7mef7qsyg0assc2upa5gy7w --home /path/to/eotsd/home/ --key-name my-key-name --keyring-backend file

{
  "pub_key_hex": "b60444181d81749c55ceb668c4432a87ab2937d0e0d66b69255c8f1913864fe3",
  "pop_hex": "12409ae3cd261933ea75577a31d988f64264dac133d986badb43523a62c2c75ea22356fbae89b83dafe4c7bdbe91216e84208a6e57af2a372d1f0e81198a23d179d7",
  "babylon_address": "bbn17ew0he6svxrqj2c7mef7qsyg0assc2upa5gy7w"
}
```

The result is output to stdout and is a json with 3 properties:

- `pub_key_hex` is the BTC public key correspondent to the private key that signed the babylon_address.
- `pop_hex` is the Proof of Possession in hex format.
- `babylon_address` is the address which the BTC private key signed.
