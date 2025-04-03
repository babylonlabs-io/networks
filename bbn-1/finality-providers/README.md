# Finality Provider Information Registry

> **⚠️  Important**: Phase-1 registrations of finality providers are now
> closed and this guide is a legacy one.
> Finality providers that intend to register to the Babylon Genesis network
> (phase-2 mainnet) -- either Phase-1 finality providers or new ones --
> should follow the
> [finality provider operation
> guide](https://github.com/babylonlabs-io/finality-provider/blob/release/v1.x/docs/finality-provider-operation.md)

This is the finality provider registration guide for the first phase of the
Babylon Bitcoin staking mainnet.

## Background

The Babylon Bitcoin staking mainnet will be launched in phases. The first phase
will only involve Bitcoin holders submitting Bitcoin staking transactions to
the Bitcoin chain to lock their Bitcoins, **without** any Proof of Stake (PoS)
chain operating to be secured by the stake. This effectively means that for
this phase, finality providers will only need to register and publish their
Extractable One Time Signature (EOTS) keys. Bitcoin stakers can make
delegations to a finality provider by associating the staking transaction with
the finality provider's EOTS public key. Finality providers do not need to run
the finality service since for this phase there is no PoS chain to be secured
by it.

The most common way for Bitcoin holders to stake is to use the Babylon Bitcoin
staking web application. This web application provides a curated list of
finality providers for the stakers to choose from for their delegations.
Besides critical information such as the EOTS public key and the commission
rate, for each finality provider, the web application also displays
human-friendly information such as the moniker and the website URL.

This repository is the place for finality providers to register such
information and all the finality providers listed in this repository will be
visible in the web application. This guide instructs finality providers on how
to get listed.

## Registration Eligibility Criteria

For security and quality reasons, strict eligibility criteria are imposed,
focusing on the finality provider's proven commitment and identity
verification. More specifically, for a finality provider to be eligible for
inclusion in this information registry, it needs to meet the following
requirements:

- having participated in the
[Babylon testnet-4](https://github.com/babylonchain/networks/tree/ac531139d5a75e575b34a80c9f8fc841cc33adab/bbn-test-4),
- to go through a know your business (KYB) process conducted by Babylon Labs, and
- to submit a pull request (PR) before the deadline of **August 20th, 12pm
coordinated universal time (UTC)**.

The pull request created should contain the finality provider's information
combined with its EOTS public key, and a signature signed over the information
using the corresponding EOTS private key.

## Missed the Registration?

After the deadline, this registration will be closed. Exceptions will only be
made rarely and on a case-by-case basis for entities that have significant
impacts and contributions to the industry. In addition, in order to be
considered, the finality provider **MUST NOT** accept any delegation before it
is registered. Otherwise, the application will be rejected, no exception.

Ineligible finality providers can still participate in this phase by accepting
Bitcoin stakes from their users. The
[Babylon Bitcoin Staking indexer](https://github.com/babylonlabs-io/babylon-staking-indexer)
will identify such delegations and display the finality providers' EOTS
public key in the web application to acknowledge their existence. However:

1. besides the EOTS public key, no more information about such finality
providers will be displayed since they are not registered.

2. the web application will not allow users to delegate to such finality
providers.

3. such finality providers' commission rate will be assumed to be 0% for any
staking reward related calculation. In other words, such finality providers
will not receive any commissions from the delegations it has received.
In later phases, the finality provider will be able to modify its commission
rate.

## Registration Steps

The registration of a finality provider requires the generation of an
Extractable-One-Time-Signature (EOTS) key pair, which will serve as the
identifier for the finality provider. The EOTS mechanism is built on top of
Schnorr signatures, the signature scheme used in Bitcoin. It is described in
more detail in the
[Bitcoin Staking light paper](ttps://docs.babylonchain.io/papers/btc_staking_litepaper(EN).pdf).
In the following, we use the terms *finality provider keys*, *BTC keys*, and
*EOTS keys* interchangeably.

In Phase-1, finality providers only need to generate their EOTS key pair and
sign their finality provider information (covered later in this guide). In
later phases, finality providers are expected to actively run the finality
provider program with their EOTS keys to provide economic security to PoS
chains and earn commissions.

### 1. Install EOTS Manager

The EOTS daemon is utilized to create the EOTS keys of the finality provider.
To follow this guide, please use the
[eotsd v0.4.0](https://github.com/babylonlabs-io/finality-provider/releases/tag/v0.4.0)
version. This is a Golang project and requires version 1.21 or later. Install
Go by following the instructions in the
[official Go installation guide](https://golang.org/doc/install).

Download the EOTS Manager code with `git clone`

```bash
$ git clone https://github.com/babylonlabs-io/finality-provider.git

Cloning into 'finality-provider'...
```

Checkout to the v0.4.0 release tag

```bash
$ cd finality-provider # cd into the project directory
$ git checkout v0.4.0

Note: switching to 'v0.4.0'.
```

At the root of the finality provider repository install the binaries

```bash
$ make install

CGO_CFLAGS="-O -D__BLST_PORTABLE__" go install -mod=readonly --tags "" --ldflags ''  ./...
```

> `eotsd` is part of the finality provider service suite, so running
`make install` also generates `fpd` which is not used in this guide.

Check if the installation succeeded by running `eotsd --help`.

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
   help, h             Shows a list of commands or help for one command

   Key management:
     keys  Command sets of managing keys for interacting with BTC eots keys.

GLOBAL OPTIONS:
   --help, -h  show help
```

### 2. Create EOTS Keys

For starters, it is needed to run the `eotsd init` command to initialize a home
directory for the EOTS manager. This directory is created in the default home
location or a location specified by the `--home` flag.

```bash
eotsd init --home /path/to/eotsd/home/
```

After initialization, the home directory will have the following structure

```bash
ls /path/to/eotsd/home/
  ├── eotsd.conf # Eotsd-specific configuration file.
  ├── logs       # Eotsd logs
```

Next, it is needed to create an EOTS key pair to identify your finality
provider by running `eotsd keys add`. This BTC EOTS key pair is stored in the
file system and will be used in later steps of the guide to sign the finality
provider information file. In future phases of the Babylon mainnet, it is
expected for this key to further be utilized to provide Bitcoin security to PoS
chains.

This command has several flag options:

- `--home` specifies the home directory of the `eotsd` in which
the new key will be stored.
- `--key-name` mandatory flag that identifies the name of the key to be
generated.
- `--passphrase` specifies the password used to encrypt the key, if such a
passphrase is required.
- `--hd-path` is the hd derivation path of the private key.
- `--keyring-backend` specifies the keyring backend, any of
`[file, os, kwallet, test, pass, memory]` are available, by default `test` is
used.
- `--recover` indicates whether the user wants to provide a seed phrase to
recover an existing key instead of creating a new one.

```shell
eotsd keys add --home /path/to/eotsd/home/ --key-name my-key-name --keyring-backend file

Enter keyring passphrase (attempt 1/3):
...

2024-04-25T17:11:09.369163Z     info    successfully created an EOTS key        {"key name": "my-key-name", "pk": "50b106208c921b5e8a1c45494306fe1fc2cf68f33b8996420867dc7667fde383"}
New key for the BTC chain is created (mnemonic should be kept in a safe place for recovery):
{
  "name": "my-key-name",
  "pub_key_hex": "50b106208c921b5e8a1c45494306fe1fc2cf68f33b8996420867dc7667fde383",
  "mnemonic": "bad mnemonic private tilt wish bulb miss plate achieve manage feel word safe dash vanish little miss hockey connect tail certain spread urban series"
}
```

> Reminder: if the `--keyring-backend` flag was used to create the key, the
same flag should be used later for accessing this key.

At the end of these steps, the EOTS BTC key pair will be generated. The key
pair or the mnemonic generated must be stored in a safe place, as it is
expected to be needed for the finality provider's participation in PoS security
in the future stages of the Babylon mainnet. Finality providers that don't have
access to their keys, will not be able to transition to later stages.

**⚠ Warning!**
Store the **mnemonic** in a safe place. The mnemonic is the only way you can
recover your keys in the case of loss or file system corruption.

### 3. Create your Finality Provider Information object

After [forking](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork)
the current repository, navigate to the `bbn-1/finality-providers` directory
and create a file under the `finality-providers/registry/${nickname}.json`
path. `${nickname}`, corresponds to a unique human-readable nickname your
finality provider can be identified with (e.g. your moniker). It should not
contain white spaces or unrecognizable characters.

Inside this file, store the following JSON information corresponding to the
finality provider.

```json
{
  "description": {
    "moniker": "<moniker>",
    "identity": "<identity>",
    "website": "<website>",
    "security_contact": "<security_contact>",
    "details": "<details>"
  },
  "eots_pk": "<finality_provider_eots_pk>",
  "commission": "<commission_decimal>"
}
```

Properties descriptions:

- `moniker`: nickname of the finality provider.
- `identity`: optional Keybase.io identity signature. It is used to retrieve
the finality provider icon, the same way Cosmos-SDK uses for validators.
- `website`: optional website link URL.
- `security_contact`: required email for security contact.
- `details`: any other optional detail information.
- `eots_pk`: the btc pub key in hex format (The `pub_key_hex` property of the
`eotsd keys add` command output).
- `commission`: the commission charged for BTC staking rewards.
The commission will be parsed as a decimal:
  - `"1.00"` represents 100% commission.
  - `"0.10"` represents  10% commission.
  - `"0.03"` represents  03% commission.

**⚠ Warning!**
The minimum commission value accepted is 3%. It will remain immutable and can't
be changed during the first phase of the Babylon mainnet. Please, define the
commission rate wisely. Bitcoin stakers may earn various types of rewards. The
commission rate you set affects every commission you earn on such rewards
through their delegations.

### 4. Sign the Finality Provider information

To attest the ownership of the EOTS public key contained in the finality
provider information file, the registry requires signing the file using the
corresponding EOTS private key. This is another step of validation that
guarantees that the information provided by the finality provider is legitimate
and not tampered with.

To sign the information file with the EOTS private key use the
`eotsd sign-schnorr [file-path]` command. This command takes as an argument one
file path, which in this case is the file created in step
[3](#3-create-your-finality-provider-information-object), hashes the file
content using sha256, and signs the hash with the EOTS private key in Schnorr
format based on the `key-name` or `eots-pk` flag. If both flags `--key-name`
and `--eots-pk` are provided, `--eots-pk` takes priority.

```shell
$ eotsd sign-schnorr bbn-1/finality-providers/registry/${nickname}.json \
  --home /path/to/eotsd/home/ --key-name my-key-name --keyring-backend file

{
  "key_name": "my-key-name",
  "pub_key_hex": "50b106208c921b5e8a1c45494306fe1fc2cf68f33b8996420867dc7667fde383",
  "signed_data_hash_hex": "b123ef5f69545cd07ad505c6d3b4931aa87b6adb361fb492275bb81374d98953",
  "schnorr_signature_hex": "b91fc06b30b78c0ca66a7e033184d89b61cd6ab572329b20f6052411ab83502effb5c9a1173ed69f20f6502a741eeb5105519bb3f67d37612bc2bcce411f8d72"
}
```

The signature is the value of the `schnorr_signature_hex` field of the above
output. A file should be created under `./finality-providers/sigs` with the
filename being the same as the finality provider information stored under
`./finality-providers/registry` but with the `.sig` extension (e.g.
`${nickname}.sig`). The content of the file should be the plain value of the
`schnorr_signature_hex` field.

**⚠ Warning!**
The signature was generated by reading the entire file data, not only the file
content. For proper verification, the exact file used for signing should be
submitted in the pull request.

### 5. Create Pull Request

The finality provider information and signature should be stored under the
`registry` and `sigs` directories respectively. Both file names should have the
same name (e.g. `${nickname}`), but with `.json` and `.sig` extensions
respectively.
**Make sure that you submit exactly the same file that the signature was
generated for to ensure proper verification**.

The validity of the finality provider data can be checked locally before
creating a pull request through the following script (replace `${nickname}`
with the filename you previously used):

```shell
$ ./bbn-1/finality-providers/scripts/verify-valid-fp.sh ${nickname}

Verifying /.../bbn-1/finality-providers/scripts/../registry/my_nickname.json
Finality Provider Moniker: my great moniker
Finality Provider Security Contact: security@email.com
Finality Provider Commission: 0.050000000000000000
Finality Provider EOTS Public Key: a89e7caf57360bc8b791df72abc3fb6d2ddc0e06e171c9f17c4ea1299e677565
Finality Provider Signature: 5e39939ccf68b8d30e134e132fe0e234b0840db3f380e17c57a0170c77235af3a555d8ea59eaacfaf43eaaa55d740549ee7f74cf844ed10dda2c81303006c348
Verifying signature with eotsd...
Verification is successful!
```

The pull request should follow the below template:

```markdown
# New ${nickname} Finality Provider

## Checklist

- [ ] I have followed the finality provider information registry
[guide](https://github.com/babylonlabs-io/networks/blob/main/bbn-1/finality-providers/README.md)
- [ ] I have backed up my mnemonic
- [ ] I have read and agree to the [Babylon Ecosystem Participant License](https://docs.babylonlabs.io/assets/files/babylon-ecosystem-participant-license.pdf) and the [Babylon Ecosystem Participant Agreement](https://docs.babylonlabs.io/assets/files/babylon-ecosystem-participant-agreement.pdf).

> [!CAUTION]
> The loss of the (generated keys + mnemonic) makes the finality provider
useless and unable to provide finality, which would lead to no transition to
later phases of the Babylon network.
```

### 6. Modifying Finality Provider Information

During the operation of the first stage of the Babylon mainnet,
a finality provider can/can't perform the following updates.

- ❌ Commission can not be changed
- ❌ Finality Provider EOTS key can not be changed
- ✅ Moniker, identity, website, security contact, and details can be changed.

To update the changeable fields, the finality provider should
modify the JSON object containing their information,
replace their old signature with a new one created using their EOTS private
key, and create a pull request updating their information.
These steps can be performed by the processes outlined previously in the guide
and the pull request submitted by the same GitHub account.
