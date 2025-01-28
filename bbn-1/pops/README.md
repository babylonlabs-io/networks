# BTC-BABY PoP Generation Spec

## Overview

This spec contains instructions on how to generate a proof-of-possession (PoP)
that bonds the ownership of both your Bitcoin key and your Babylon key
(BTC-BABY PoP or just PoP for short) in the format of a JSON file. For BTC
stakers, the BTC key is the Schnorr public key used in signing the staking
transaction. For finality providers, the BTC key is the EOTS public key.
In general, the process is as follows:

1. Create Babylon keys and address that receives BABY tokens.
2. Generate PoP in a JSON file.
3. Check validity of the JSON file.

## 1. Create Babylon keys and addresses

Your Babylon keys will be used to specify the address in which the BABY token
will be delivered. In the following, we outline the steps to create your
Babylon keys and retrieve your address.

### 1.1. Install the `babylond` binary

The `babylond` binary is utilized to create your Babylon keys. This guide
requires the usage of the
[babylond v1.0.0-rc.x](https://github.com/babylonlabs-io/babylon/releases/tag/v1.0.0-rc.3) version.
Below we outline the steps to build the binary.

First, clone the official Babylon GitHub repository.

```bash
$ git clone https://github.com/babylonlabs-io/babylon.git
Cloning into 'babylon'...
```

Enter the directory which you have cloned the repository in and checkout to
the `v1.0.0-rc.3` release tag.

```bash
$ cd babylon
$ git checkout v1.0.0-rc.3
Note: switching to 'v1.0.0-rc.3'.
```

Finally, execute the `make install` command to install the binary.

```bash
$ make install
go build -mod=readonly -tags "netgo ledger mainnet" -ldflags '-X github.com/cosmos/cosmos-sdk/version.Name=babylon -X github.com/cosmos/cosmos-sdk/version.AppName=babylond -X github.com/cosmos/cosmos-sdk/version.Version=v1.0.0-rc.3 -X github.com/cosmos/cosmos-sdk/version.Commit=b5646552a1606e38fcdfa97ed2606549b9a233f7 -X "github.com/cosmos/cosmos-sdk/version.BuildTags=netgo,ledger" -w -s' -trimpath -o /home/rafilx/projects/github.com/babylonlabs-io/babylon/build/  ./...
```

The binary should now be installed. You can check if the installation
succeeded by running `babylond` version.

```bash
$ babylond version
v1.0.0-rc.3
```

### 1.2. Create Babylon Keys

You can create a Babylon key pair using the `babylond keys add` command. The
Babylon key pair is stored in the file system and will be used in later steps
of the guide.

This command has one parameter `<baby-key-name>` and several flag options:

- `--home` specifies the home directory for the babylond daemon in which
  the newly created key will be stored.
- `--passphrase` specifies the password used to encrypt the key. This is
  an optional flag used in the case of an encrypted keyring (recommended).
- `--hd-path` is the HD derivation path of the private key.
- `--keyring-backend` specifies the keyring backend. Any
  of `[file, os, kwallet, test, pass, memory]` are available. You can find
  more details about the available keyring backends
  [here](https://docs.cosmos.network/v0.46/run-node/keyring.html#available-backends-for-the-keyring).
  By default, the test keyring backend is used, although it is recommended
  that you use an encrypted keyring.
- `--recover` indicates whether the user wants to provide a seed phrase to
  recover an existing key instead of creating a new one. This flag should only
  be used if the user wants to import an existing keyring or seed phrase.

```bash
$~ babylond keys add my-baby-key-name --home /path/to/babylon/home/ --keyring-backend file
Enter keyring passphrase (attempt 1/3):
...
- address: bbn17ew0he6svxrqj2c7mef7qsyg0assc2upa5gy7w
  name: my-baby-key-name
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"A5UjwURAlm0ndhMLfmNKIe4wzc8NnsBkNOgr7Ogx6kQQ"}'
  type: local
**Important** write this mnemonic phrase in a safe place.
It is the only way to recover your account if you ever forget your password.
bad mnemonic private split escape wage suit banner affair home fine rent erosion hurry bicycle throw tilt warfare silk rude real frown cabin few
```

> Reminder: if the `--keyring-backend` flag was used to create the key,
> the same flag should be used later for accessing this key. At the end
> of these steps, the Babylon key pair will be generated. The key pair
> and the mnemonic generated must be stored in a safe place.
> 
> **⚠ Warning!**
> 
> Store the **mnemonic** in a safe place. The mnemonic is the only way
> you can recover your keys in the case of loss or file system corruption.
> 

### 1.3. Import existing wallet

If you wish to import an existing wallet with your mnemonic seed phrase,
you can use the below command. Note that not all of the params below are
required, please see the parameters list below to see which are optional.

`babylond keys add <wallet-name> --recover --hd-path <hd-path> --home <home> --keyring-backend <backend>`

Now you will be prompted for your `bip39 mnemonic` and you can enter
your `Enter your 24-word seed phrase`.

The output of the above command will be similar to the following:

```bash
- address: bbn1gsapezku653vxxmxvurh73s5j8lvxh6vzc6jjq
  name: mykey
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AyFqOcOQeDTYpJctaWiQZ6SuM5y1a3batlsx6l2dgBAw"}'
  type: local
```

## 2. Generate PoP for finality providers

⚠️ This document assumes that the finality provider has been created and
registered for phase-1 following the instructions in the
[official documentation](https://github.com/babylonlabs-io/networks/tree/main/bbn-1/finality-providers).

### 2.1. Setup the EOTS Daemon

The EOTS daemon is utilized to create and manage the EOTS key of the
finality provider. If you participated as a finality provider during
the first phase of the Babylon mainnet, you should have already created
your EOTS keys and stored them safely
[following this guide](https://github.com/babylonlabs-io/networks/tree/main/bbn-1/finality-providers).

Note that for the purposes of this guide, you will need to upgrade
your `eotsd` version to version `v0.4.3` (previously `v0.4.0` was used).
To do this, please follow the instructions below.

First, download the finality provider toolset repository with `git clone`

```bash
$ git clone https://github.com/babylonlabs-io/finality-provider.git

Cloning into 'finality-provider'...
```

Then, checkout to the `v0.4.3` release tag:

```
$ cd finality-provider # cd into the project directory
$ git checkout v0.4.3

Note: switching to 'v0.4.3'.
```

At the root of the finality provider repository install the finality provider
binaries using make install.

```bash
$ make install

CGO_CFLAGS="-O -D__BLST_PORTABLE__" go install -mod=readonly --tags "" --ldflags ''  ./...
```

> ⚠ `eotsd` is part of the finality provider service suite, so
> running `make install` also generates `fpd` which is not used in this guide.
> 

You can check if the installation succeeded by running `eotsd --help`.

```bash
$ eotsd --help
NAME:
   eotsd - Extractable One Time Signature Daemon (eotsd).

USAGE:
   eotsd [global options] command [command options] [arguments...]

COMMANDS:
   start               Start the Extractable One Time Signature Daemon.
   init                Initialize the eotsd home directory.
   sign-schnorr        Signs a Schnorr signature over arbitrary data with the EOTS private key.
   verify-schnorr-sig  Verify a Schnorr signature over arbitrary data with the given public key.
   pop                 Proof of Possession commands
   help, h             Shows a list of commands or help for one command

   Key management:
     keys  Command sets of managing keys for interacting with BTC eots keys.

GLOBAL OPTIONS:
   --help, -h  show help
```

### 2.2. Create the Proof of Possession (PoP)

The PoP can be created and exported using the `eotsd export-pop` command:

```bash
$~ eotsd pop export --home /path/to/eotsd/home/ --key-name <my-key-name> --keyring-backend file \
  --baby-home /path/to/babylon/home/ --baby-key-name <my-baby-key-name> --baby-keyring-backend file \
  --output-file /path/to/pop_fp.json
{
  "eotsPublicKey": "3d0bebcbe800236ce8603c5bb1ab6c2af0932e947db4956a338f119797c37f1e",
  "babyPublicKey": "A0V6yw74EdvoAWVauFqkH/GVM9YIpZitZf6bVEzG69tT",
  "babySignEotsPk": "AOoIG2cwC2IMiJL3OL0zLEIUY201X1qKumDr/1qDJ4oQvAp78W1nb5EnVasRPQ/XrKXqudUDnZFprLd0jaRJtQ==",
  "eotsSignBaby": "pR6vxgU0gXq+VqO+y7dHpZgHTz3zr5hdqXXh0WcWNkqUnRjHrizhYAHDMV8gh4vks4PqzKAIgZ779Wqwf5UrXQ==",
  "babyAddress": "bbn17ew0he6svxrqj2c7mef7qsyg0assc2upa5gy7w"
}
```

> Detailed explanation about the output can be found
> [here](https://github.com/babylonlabs-io/finality-provider/blob/c1a77bfbb54b9ac0891c2f3b1b39ae0f88885261/docs/pop_format_spec.md#L1).
> 

This command has several flag options:

- `--home` specifies the home directory of the EOTS daemon in which the EOTS
  key created for Phase-1 has been stored. Please refer to the
  [Phase-1](https://github.com/babylonlabs-io/networks/tree/main/bbn-1/finality-providers#2-create-eots-keys)
  registration guide if you want a reminder on where you stored your EOTS
  home directory. If you didn't store the key files, only the mnemonic, use
  the `eotsd keys add --recover` flag option to prompt input the mnemonic
  and recover the keys as specified by this
  [guide](https://github.com/babylonlabs-io/finality-provider/blob/main/docs/finality-provider-operation.md#322-import-an-existing-eots-key).
- `--key-name` specified the name assigned to the EOTS key (is the value of
  the flag `--key-name` specified when running `eotsd keys add --key-name ...` ).
- `--passphrase` specifies the password used to decrypt the key. The
  passphrase is required if it was specified when creating the EOTS
  key `eotsd keys add --passphrase ...`.
- `--eots-pk` is the EOTS public key which is specified as `eots_pk` in
  the [GitHub registry](https://github.com/babylonlabs-io/networks/tree/main/bbn-1/finality-providers/registry)
  for each finality provider (the `--eots-pk` flag takes priority over
  the `--key-name` flag, which requires `eots.db` in the `--home` directory).
- `--keyring-backend` specifies the keyring backend. Any
  of `[file, os, kwallet, test, pass, memory]` are available. You can find
  more details about the available keyring backends [here](https://docs.cosmos.network/v0.46/run-node/keyring.html#available-backends-for-the-keyring). By default,
  the `test` keyring backend is used, although it is recommended that
  you use an encrypted keyring.
- `--baby-home` specifies the Babylon home directory of the Babylon key
  created in [step 1](#1-create-babylon-keys-and-addresses).
- `--baby-key-name` specifies the Babylon key name argument of the key
  created in [step 1](#1-create-babylon-keys-and-addresses).
- `--baby-keyring-backend` specifies the Babylon keyring backend of the key
  created in [step 1](#1-create-babylon-keys-and-addresses).
- `--output-file` specifies the file path of the raw JSON result. Note that
  if the flag is not specified, the JSON file won't be generated.

### 2.3. Validate the Proof of Possession (PoP)

To validate the JSON file that contains the PoP, run `eotsd pop validate` command:

```bash
 $ eotsd pop validate /path/to/pop.json
 Proof of Possession is valid!
```

If `Proof of Possession is valid!` is shown, the pop is successfully validated.

## 3. Generate PoP for stakers

It is possible that the stakers BTC keys are stored in different type of
wallets, so one may need to develope their own software to generate PoP
for stakers. For the format of PoP and how it is generated, refer
to [3.3. Create the Proof of Possession](#33-create-the-proof-of-possession-pop).
Below is instructions of using `btc-staker`.

### 3.1. Prepare the BTC wallet

Launch bitcoind instance and load the wallet that was used to stake in phase-1
(see [instructions](https://github.com/babylonlabs-io/btc-staker) of bitcoind for phase-1):

```bash
$ bitcoind bitcoin-cli -rpcuser=user -rpcpassword=pass loadwallet "walletName"
```

where:

- `-rpcuser=user` is the username for the bitcoind RPC
- `-rpcpassword=pass` is the password for the bitcoind RPC
- `loadwallet "walletName"` is the name of the wallet used to stake in phase-1

### 3.2 Setup the `stakercli`

`stakercli` is used to communicate between your cosmos keyring and bitcoind
wallet it order to create valid proof of possession payload.

First, download the `btc-staker` repository with `git clone`

```bash
$ git clone https://github.com/babylonlabs-io/btc-staker.git
Cloning into 'btc-staker'...
```

Then, checkout to the `main` branch:

```bash
$ cd btc-staker # cd into the project directory
$ git checkout 'main'
Note: switching to 'main'.
```

At the root of the btc-staker repository install the btc-stker binaries
using `make install`.

```bash
$ make install
CGO_CFLAGS="-O -D__BLST_PORTABLE__" go install -mod=readonly --tags "" --ldflags ''  ./...
```

You can check if the installation succeeded by running `stakercli --help`.

```bash
$ stakercli  --help
NAME:
   stakercli - Bitcoin staking controller
USAGE:
   stakercli [global options] command [command options] [arguments...]
COMMANDS:
   help, h  Shows a list of commands or help for one command
   Admin:
     admin, ad  Different utility and admin commands
   Daemon commands:
     daemon, dn  More advanced commands which require staker daemon to be running.
   PoP commands:
     pop  Commands realted to generation and verification of the Proof of Possession
   transaction commands:
     transaction, tr  Commands related to Babylon BTC transactions Staking/Unbonding/Slashing
GLOBAL OPTIONS:
   --btc-network value            Bitcoin network on which staking should take place (default: "testnet3")
   --btc-wallet-host value        Bitcoin wallet rpc host (default: "127.0.0.1:18554")
   --btc-wallet-rpc-user value    Bitcoin wallet rpc user (default: "user")
   --btc-wallet-rpc-pass value    Bitcoin wallet rpc password (default: "pass")
   --btc-wallet-passphrase value  Bitcoin wallet passphrase
   --help, -h                     show help
```

### 3.3. Create the Proof of Possession (PoP)

The PoP can be created and exported using the `stakercli pop gcp` command:

```bash
 $ stakercli pop gcp --btc-address bc1qcpty6lpueassw9rhfrvkq6h0ufnhmc2nhgvpcr \
   --baby-address bbn1xjz8fs9vkmefdqaxan5kv2d09vmwzru7jhy424 \
   --keyring-dir /path/to/cosmos/keyring \
   --keyring-backend file --btc-wallet-host localhost:8332 \
   --output-file /path/to/pop.json
 {
    "babyAddress": "bbn1xjz8fs9vkmefdqaxan5kv2d09vmwzru7jhy424",
    "btcAddress": "bc1qcpty6lpueassw9rhfrvkq6h0ufnhmc2nhgvpcr",
    "btcPublicKey": "79f71003589158b2579345540b08bbc74974c49dd5e0782e31d0de674540d513",
    "btcSignBaby": "AkcwRAIgcrI2IdD2JSFVIeQmtRA3wFjjiy+qEvqbX57rn6xvWWECIDis7vHSJeR8X91uMQReG0pPQFFLpeM0ga4BW+Tt2V54ASEDefcQA1iRWLJXk0VUCwi7x0l0xJ3V4HguMdDeZ0VA1RM=",
    "babySignBtc": "FnYTm9ZbhJZY202R9YBkjGEJqeJ/n5McZBpGH38P2pt0YRcjwOh8XgoeVQTU9So7/RHVHHdKNB09DVmtQJ7xtw==",
    "babyPublicKey": "Asezdqkvh+kLbuD75DirSwi/QFbJjFe2SquiivMaPS65"
}
```

This command will create a JSON file that contains the pop result to the
specified output path. It has several flag options:

- `--btc-address` is the address of the BTC key used when staking in
  phase-1. Bech-32 encoded.
- `--baby-address` is the address of the BABY key created
  in [step-1](#1-create-babylon-keys-and-addresses). Bech-32 encoded.
- `--keyring-dir` is the directory of the keyring created
  in [step-1](#1-create-babylon-keys-and-addresses).
- `--keyring-backend` is the backend of the keyring created
  in [step-1](#1-create-babylon-keys-and-addresses).
- `--btc-wallet-host` is the host of the BTC wallet, default for BTC
  mainnet is `localhost:8332`.
- `--output-file` specifies the file path of the raw JSON result. Note
  that if the flag is not specified, the JSON file won't be generated.

This command will produce json output:

```bash
{
    "babyAddress": "bbn1xjz8fs9vkmefdqaxan5kv2d09vmwzru7jhy424",
    "btcAddress": "bc1qcpty6lpueassw9rhfrvkq6h0ufnhmc2nhgvpcr",
    "btcPublicKey": "79f71003589158b2579345540b08bbc74974c49dd5e0782e31d0de674540d513",
    "btcSignBaby": "AkcwRAIgcrI2IdD2JSFVIeQmtRA3wFjjiy+qEvqbX57rn6xvWWECIDis7vHSJeR8X91uMQReG0pPQFFLpeM0ga4BW+Tt2V54ASEDefcQA1iRWLJXk0VUCwi7x0l0xJ3V4HguMdDeZ0VA1RM=",
    "babySignBtc": "FnYTm9ZbhJZY202R9YBkjGEJqeJ/n5McZBpGH38P2pt0YRcjwOh8XgoeVQTU9So7/RHVHHdKNB09DVmtQJ7xtw==",
    "babyPublicKey": "Asezdqkvh+kLbuD75DirSwi/QFbJjFe2SquiivMaPS65"
}
```

where:

- `babyAddress` is the address of the BABY key created in step 1.
  Bech-32 encoded.
- `btcAddress` is the address of corresponding to the BTC key used
  when staking in phase-1. Bech-32 encoded.
- `btcPublicKey` is the staker public key used. Hex encoded.
- `btcSignBaby` is the BI322 signature made by `btcAddress`. Base64 encoded.
- `babySignBtc` is the ADR36 signature made by `babyPublicKey`. Base64 encoded.
- `babyPublicKey` is the Babylon public key, corresponding to
  the `babyAddress`. Base64 encoded.

### 3.4. Validate the Proof of Possession (PoP)

To validate the JSON file that contains the PoP,
run `stakercli pop validate` command:

```bash
 $ stakercli pop validate /path/to/pop.json
 Proof of Possession is valid!
```

If `Proof of Possession is valid!` is shown, the pop is successfully validated.

## 4. Create Pull Request

The PoP JSON files for finality providers and stakers are stored under the
`fps` and `stakers` directories respectively. Each file should be identified
by a unique name, e.g., `${btc_pk_pop}.json`, with `.json` extension.

The pull request should be titled with the company's name.
