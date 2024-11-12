## Introduction

Finality providers are responsible for voting at a finality round on top
of [CometBFT](https://github.com/cometbft/cometbft). Similar to any native PoS
validator, a finality provider can receive voting power delegations from BTC
stakers, and can earn commission from the staking rewards denominated in Babylon
tokens.

The finality provider toolset does not have any special hardware requirements
and can operate on standard mid-sized machines running a UNIX-flavored operating
system. It consists of the following programs:

- _Babylon full node_: An instance of a Babylon node connecting to the Babylon
network. Running one is not a strict requirement, but it is recommended for
security compared to trusting a third-party RPC node.  - _Extractable One-Time
Signature (EOTS) manager_: A daemon responsible for securely maintaining the
finality provider’s private key and producing extractable one time signatures
from it.  - _Finality Provider_: A daemon managing the finality provider. It
connects to the EOTS manager to generate EOTS public randomness and finality
votes for Babylon blocks, which it submits to Babylon through the node
connection.

The following graphic demonstrates the interconnections for parts of the above
programs.



## Install Finality Provider Binary <!-- TODO: check add in the correct tag for
the testnet --> Download [Golang 1.21](https://go.dev/dl) 

Using the go version 1.21.x (where x is any patch version like 1.21.0, 1.21.1,
etc.) Once installed run:

```shell go version ```

Subsequently clone the finality provider
[repository](https://github.com/babylonlabs-io/finality-provider).

```shell git clone https://github.com/babylonchain/finality-provider.git ```

Once the `babylon` repository is downloaded then checkout the corresponding tag
for `bbn-testnet-5`.

``` shell git checkout <tag> ```

You should now have the repository on your machine. Next navigate into the
repository you just cloned and run the following:

```shell make install ```

The above command will build and install the following binaries
to `$GOPATH/bin`:

- `eotsd`: The daemon program for the EOTS manager.  - `fpd`: The daemon program
for the finality-provider.  - `fpcli`: The CLI tool for interacting with the
finality-provider daemon.

Now it has successfully compiled, lets check with the following command:

```shell eotsd ```

Which will give us a list of available actions.

```shell NAME:
   eotsd - Extractable One Time Signature Daemon (eotsd).

USAGE:
   eotsd [global options] command [command options] [arguments...]

COMMANDS:
   start               Start the Extractable One Time Signature Daemon.  init
   Initialize the eotsd home directory.  sign-schnorr        Signs a Schnorr
   signature over arbitrary data with
...
```

Now lets do the same with the finality provider daemon. Run:

```shell fpd ```

If your shell cannot find the installed binaries, make sure `$GOPATH/bin` is in
the `$PATH` of your shell. Usually these commands will do the job

```shell export PATH=$HOME/go/bin:$PATHecho 'export PATH=$HOME/go/bin:$PATH' >>
~/.profile ```

## Install Babylon Binary

First clone the babylon [repository](https://github.com/babylonlabs-io/babylon).

```shell git clone git@github.com:babylonlabs-io/babylon.git ```

Once the `babylon` repository is downloaded then checkout the corresponding tag
for `bbn-testnet-5`.

``` shell git checkout <tag> ```

You should now have the repository on your machine. Next navigate into the
repository you just cloned and run the following:

```shell make install ```

This command does the following: - Builds the daemon - Compile all Go packages
in the project - Installs the binary - Makes the `babylond` command globally
accessible from your terminal - Build and install the binaries to `$GOPATH/bin`:

And should return something such as below:

```shell go install -mod=readonly -tags "netgo ledger mainnet" -ldflags '-X
github.com/cosmos/cosmos-sdk/version.Name=babylon -X
github.com/cosmos/cosmos-sdk/version.AppName=babylond -X
github.com/cosmos/cosmos-sdk/version.Version=v0.13.0 -X
github.com/cosmos/cosmos-sdk/version.Commit=976e94b926dcf287cb487e8f35dbf400c7d930cc
-X "github.com/cosmos/cosmos-sdk/version.BuildTags=netgo,ledger" -w -s'
-trimpath  ./...  ```

Now it has successfully compiled lets check, with the following command:

```shell babylond ```

Which will give us a list of available actions.

```shell Available Commands:
  add-genesis-account Add a genesis account to genesis.json collect-gentxs
  Collect genesis txs and output a genesis.json file comet
  CometBFT subcommands config              Utilities for managing application
  configuration ...
```

If you're having issues, you might not have successfully saved in your `gopath`

If it hasn't saved successfully in your `gopath` then it might have saved in the
`./build` directory, so instead use the following from the project root
directory.

```
./build/babylond
```

## Setup your node, home directory and configure

Next we initialize the node and home directory. It should generate all of the
necessary files such as `app.toml`, `client.toml`, `genesis.json` with the below
command.

```shell babylond init <monkier> --chain-id bbn-test-5 --home=./nodeDir ```

The `<moniker>` is a unique identifier for your node. So for example `node0`.

  Next we should navigate to `app.toml`, update the following section:

```shell Base configuration minimum-gas-prices = "0.005ubbn" iavl-cache-size = 0
iavl-disable-fastnode=true

[btc-config] # Configures which bitcoin network should be used for checkpointing
# valid values are: [mainnet, testnet, simnet, signet, regtest] network =
"signet" ```

In `app.toml` under `[btc-network]`change network to `signet` and under `Base
Configuration` set `iavl-cache-size = 0` and `iavl-disable-fastnode=true`
instead of what is listed in the automatically generated template. Additionally,
add `minimum-gas-prices = "0.005ubbn"`

Navigate to `config.toml` add in the `seed` such as below.

```shell
 P2P Configuration Options

# Comma separated list of seed nodes to connect to seeds =
"8fa2d1ab10dfd99a51703ba760f0ef555ae88f36@16.162.207.201:26656" ```

We next want to add in the `genesis.json` file. To do this, either copy the
genesis file from `https://rpc.devnet.babylonlabs.io/genesis` or we can use the
terminal with the following command.

```shell wget
https://github.com/babylonlabs-io/networks/raw/main/bbn-test-5/genesis.tar.bz2
tar -xjf genesis.tar.bz2 && rm genesis.tar.bz2 mv genesis.json
~/.babylond/config/genesis.json ```

This file needs to overwrite the existing genesis file in the
`~/.babylond/config/genesis.json` and please ensure that the `chain-id` is
correct. The chain id is what you used in the `babylond init` command above.

### Sync Node

We are now ready to sync the node.

```shell babylond start --chain-id=bbn-test-5 --home=./nodeDir
--minimum-gas-prices=0.005ubbn --x-crisis-skip-assert-invariants ```

Lets go through the flags of the above command:

- `start`: This is the command to start the Babylon node.  - `--chain-id
bbn-test-5`: Specifies the ID of the blockchain network you're connecting to.  -
`--home=./nodeDir`: Sets the directory for the node's data and configuration
files and is dependant on where the files were generated for you from the
initialization. In this case, it's using a directory named "nodeDir" in the
current path.  - `--minimum-gas-prices=0.005ubbn`: This flag sets the minimum
gas price for transactions the node will accept. This can also be manually set
in the `app.toml - `--x-crisis-skip-assert-invariants` : This flag is used to
skip the crisis module's invariant checks, used during testing and development.

## Setting up the EOTS Manager

After a node and a keyring have been set up, the operator can set up and run the
Extractable One Time Signature (EOTS) manager daemon.

The EOTS daemon is responsible for managing EOTS keys, producing EOTS
randomness, and using them to produce EOTS signatures. To read more on the EOTS
Manager see [here](#)

The `eotsd init` command initializes a home directory for the EOTS manager. You
can wish to set/change your home directory with the `--home` tag. For example
we use `./eotsKey`

```shell eotsd init --home <path> ```

#### Add an EOTS key

Then you will need to create an EOTS key:

``` eotsd keys add --key-name <key-name> --home <path> ```

This command will create a new EOTS key and store it in the keyring.
The user will be prompted to enter and confirm a passphrase. Ensure this is
performed before starting the daemon.

What should return is something similar to the following:

```json {
    "name": "eots", "pub_key_hex":
    "e1e72d270b90b24f395e76b417218430a75683bd07cf98b91cf9219d1c777c19",
    "mnemonic": "parade hybrid century project toss gun undo ocean exercise
    figure decorate basket peace raw spot gap dose daring patch ski purchase
    prefer can pair"
} ``` #### Starting the EOTS Daemon

You can start the EOTS daemon using the following command:

```shell eotsd start --home <path> ```

This will start the EOTS rpc server at the address specified
in `eotsd.conf` under the `RpcListener` field, which is by default set
to `127.0.0.1:12582`. You can change this value in the configuration file or
override this value and specify a custom address using
the `--rpc-listener` flag.

```shell 2024-10-30T12:42:29.393259Z     info    Metrics server is starting
{"addr": "127.0.0.1:2113"} 2024-10-30T12:42:29.393278Z     info    RPC server
listening    {"address": "127.0.0.1:12582"} 2024-10-30T12:42:29.393363Z     info
EOTS Manager Daemon is fully active!  ```

**Note**: It is recommended to run the `eotsd` daemon on a separate machine or
network segment to enhance security. This helps isolate the key management
functionality and reduces the potential attack surface. You can edit
the`EOTSManagerAddress` in the configuration file of the finality provider to
reference the address of the machine where `eotsd` is running.

## Setting up the Finality Provider

The Finality Provider Daemon is responsible for monitoring for new Babylon
blocks, committing public randomness for the blocks it intends to provide
finality signatures for, and submitting finality signatures. To read more on
Finality Providers please see [here](#)

The `fpd init` command initializes a home directory for the EOTS manager. You
can wish to set/change your home directory with the `--home` tag.  For the home
`<path>` we have used `./fp`

``` fpd init  --home <path> ```

Note: will return `service injective.evm.v1beta1.Msg does not have
cosmos.msg.v1.service proto annotation`

#### Add key for the finality provider on the Babylon chain

The keyring is maintained by the finality provider daemon, this is local storage
of the keys that the daemon uses. The account associated with this key exists on
the babylon chain.

Use the following command to add a key for your finality provider:

```shell fpd keys add --keyname <key-name> --keyring-backend test --home <path>
```

We use `--keyring-backend test`, which specifies which backend to use for the
keyring, `test` stores keys unencrypted on disk. For production environments,
use `file` or `os` backend.


 There are three options for the keyring backend:

 `test`: Stores keys unencrypted on disk. It’s meant for testing purposes and
 should never be used in production.  `file`: Stores encrypted keys on disk,
 which is a more secure option than test but less secure than using the OS
 keyring.  `os`: Uses the operating system's native keyring, providing the
 highest level of security by relying on OS-managed encryption and access
 controls.

This command will create a new key pair and store it in your keyring. The output
should look similar to the below.

``` - address: bbn19gulf0a4yz87twpjl8cxnerc2wr2xqm9fsygn9
  name: finality-provider pubkey:
  '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AhZAL00gKplLQKpLMiXPBqaKCoiessoewOaEATKd4Rcy"}'
  type: local
```

>Note: Please verify the `chain-id` from the Babylon RPC
node [https://rpc.testnet5.babylonlabs.io/status](https://rpc.testnet5.babylonlabs.io/status)

 >The configuration below requires to point to the path where this keyring is
 stored `KeyDirectory`. This `Key` field stores the key name used for
 interacting with the babylon chain and will be specified along with
 the `KeyringBackend`field in the next step. So we can ignore the setting of the
 two fields in this step.

Once the node is initialized with the above command. It should generate a
`fpd.config` Edit the `config.toml` to set the necessary parameters with the
below

```shell [Application Options] EOTSManagerAddress = 127.0.0.1:12582 RpcListener
= 127.0.0.1:12581

[babylon] Key = <finality-provider-key-name-signer> // the key you used above
ChainID = bbn-test-5 RPCAddr = http://127.0.0.1:26657 GRPCAddr =
https://127.0.0.1:9090 KeyDirectory = ./fpKey ``` ## Starting the Finality
provider Daemon

Before creating and registering your finality provider, you need to start the
daemon first.

We can use the basic start command below:

``` fpd start \ --home ./fp \ ```

This starts the FPD daemon and specifies the address where the RPC server will
listen for incoming requests from CLI commands. The RPC server acts as an
interface between CLI commands and the daemon.

Upon successful execution, you should see logs indicating the finality provider
creation process:

``` 2024-11-08T08:41:54.901105Z     info    successfully connected to a remote
EOTS manager {"address": "127.0.0.1:12582"} 2024-11-08T08:41:54.941891Z     info
Starting FinalityProviderApp 2024-11-08T08:41:54.942083Z     info    starting
sync FP status loop    {"interval seconds": 30} 2024-11-08T08:41:54.942445Z
info    starting metrics update loop    {"interval seconds": 0.1}
2024-11-08T08:41:54.943376Z     info    Metrics server is starting      {"addr":
"127.0.0.1:2112"} 2024-11-08T08:41:54.943464Z     info    RPC server listening
{"address": "127.0.0.1:12581"} 2024-11-08T08:41:54.943490Z     info    Finality
Provider Daemon is fully active!  2024-11-08T08:43:40.814176Z     info
successfully created a finality-provider        {"btc_pk":
"cf0f03b9ee2d4a0f27240e2d8b8c8ef609e24358b2eb3cfd89ae4e4f472e1a41", "addr":
"bbn1ht2nxa6hlyl89m8xpdde9xsj40n0sxd2f9shsq", "key_name": "finality-provider"}
```

The above will start the Finality provider RPC server at the address specified
in `fpd.conf` under the `RpcListener` field, which has a default value
of `127.0.0.1:12581`. You can change this value in the configuration file or
override this value and specify a custom address using
the `--rpc-listener` flag.

To start the daemon with a specific finality provider instance, use
the `--btc-pk` flag followed by the hex string of the BTC public key of the
finality provider (`btc_pk_hex`) in the next step

All the available CLI options can be viewed using the `--help` flag. These
options can also be set in the configuration file.

## Create Finality Provider

The `create-finality-provider` command initializes a new finality provider
instance locally. This command:

- Generates a BTC public key that uniquely identifies your finality provider -
Creates a Babylon account to receive staking rewards

``` fpd create-finality-provider \ --daemon-address 127.0.0.1:12581 \ --chain-id
bbn-test-5 \ --commission 0.05 \ --key-name finality-provider \ --moniker
"MyFinalityProvider" \ --website "https://myfinalityprovider.com" \
--security-contact "security@myfinalityprovider.com" \ --details "finality
provider for the Babylon network" \ --home ./fp \ --passphrase "passphrase" ```

Required parameters: - `--chain-id`: The Babylon chain ID (`bbn-test-5`) -
`--commission`: The commission rate (between 0 and 1) that you'll receive from
delegators - `--key-name`: Name of the key in your keyring for signing
transactions - `--moniker`: A human-readable name for your finality provider

Optional parameters: - `--website`: Your finality provider's website -
`--security-contact`: Contact email for security issues - `--details`:
Additional description of your finality provider - `--daemon-address`: RPC
address of the finality provider daemon (default: 127.0.0.1:12581)

Upon successful creation, the command will return a JSON response containing
your finality provider's details:

``` {
    "fp_addr": "bbn1ht2nxa6hlyl89m8xpdde9xsj40n0sxd2f9shsq", "btc_pk_hex":
    "cf0f03b9ee2d4a0f27240e2d8b8c8ef609e24358b2eb3cfd89ae4e4f472e1a41",
    "description": {
	"moniker": "MyFinalityProvider", "website":
	"https://myfinalityprovider.com", "security_contact":
	"security@myfinalityprovider.com", "details": "finality provider for the
	Babylon network"
    }, "commission": "0.050000000000000000", "status": "CREATED"
} ```

The response includes: - `fp_addr`: Your Babylon account address for receiving
rewards - `btc_pk_hex`: Your unique BTC public key identifier (needed for
registration) - `description`: Your finality provider's metadata - `commission`:
Your set commission rate - `status`: Current status of the finality provider

## Register Finality Provider

The `register-finality-provider` command registers your finality provider on the
Babylon chain. This command requires:

1. The BTC public key (obtained from the `create-finality-provider` command) 2.
A funded Babylon account (needs BBN tokens for transaction fees) 3. A running
FPD daemon

``` fpd register-finality-provider \
cf0f03b9ee2d4a0f27240e2d8b8c8ef609e24358b2eb3cfd89ae4e4f472e1a41 \
--daemon-address 127.0.0.1:12581 \ --passphrase "Zubu99012" \ --home ./fp \ ```

> Note: The BTC public key (`cf0f03...1a41`) is obtained from the previous
`create-finality-provider` command.

If successful, the command will return a transaction hash:

``` { "tx_hash":
"C08377CF289DF0DC5FA462E6409ADCB65A3492C22A112C58EA449F4DC544A3B1" } ```

 You can query this hash to confirm the transaction was successful by navigating
 to the babylon chain and making a query, such as below:

```shell babylond query tx <transaction-hash> --chain-id bbn-test-5 ```

>Note: This query must be executed using the Babylon daemon (`babylond`), not
the finality provider daemon (`fpd`), as the registration transaction is
recorded on the Babylon blockchain.

The hash returned should look something similar to below:

```shell
  type: message
- attributes:
  - index: true
    key: fp value:
    '{"addr":"bbn1ht2nxa6hlyl89m8xpdde9xsj40n0sxd2f9shsq","description":{"moniker":"MyFinalityProvider","identity":"","website":"https://myfinalityprovider.com","security_contact":"security@myfinalityprovider.com","details":"Reliable
      finality provider for the Babylon
      network"},"commission":"0.050000000000000000","btc_pk":"cf0f03b9ee2d4a0f27240e2d8b8c8ef609e24358b2eb3cfd89ae4e4f472e1a41","pop":{"btc_sig_type":"BIP340","btc_sig":"YJgc6NU7Z011imqSfPc9w/Namr1hFj48oTlEjGqbAVvHJv+9h3p/1shTohEb1g0fDWij7Ti9yKZzjAgNVepObA=="},"slashed_babylon_height":"0","slashed_btc_height":"0","jailed":false,"consumer_id":"euphrates-0.5.0"}'
  - index: true
    key: msg_index value: "0"
  type: babylon.btcstaking.v1.EventNewFinalityProvider
gas_used: "82063" gas_wanted: "94429" height: "66693" info: "" logs: [] raw_log:
"" ```

When a finality provider is created, it's associated with two key elements:

**a) BTC Public Key:** - This serves as the unique identifier for the finality
provider.  - It's derived from a Bitcoin private key, likely using the secp256k1
elliptic curve.  - This key is used in the Bitcoin-based security model of
Babylon.

**b) Babylon Account:** - This is an account on the Babylon blockchain.  - It's
where staking rewards for the finality provider are sent.  - This account is
controlled by the key you use to create and manage the finality provider (the
one you added with fpd keys add).

This dual association allows the finality provider to interact with both the
Bitcoin network (for security) and the Babylon network (for rewards and
governance).

## Slashing

Slashing is a penalty mechanism for finality providers who engage in malicious
behavior. The system monitors finality provider behavior and can transition them
through several states.

### Slashing Conditions

Slashing occurs when a finality provider **double signs**. This occurs when a
finality provider signs conflicting blocks at the same height. This results in
the extraction of the provider's private key and automatically triggers shutdown
of the finality provider.

### Slashing States

A finality provider can be in the following states: - **CREATED**: Awaiting
registration - **REGISTERED**: Registered but no delegated stake - **ACTIVE**:
Delegated and able to vote - **INACTIVE**: Delegations reduced to zero but not
slashed - **SLASHED**: Has been penalized for misbehavior and subsequently shut
down - **JAILED**: Temporarily suspended from operation

### Slashing Process

When a finality provider is slashed: 1. Their status is changed to `SLASHED` 2.
The instance is stopped and removed from operation 3. They cannot be restarted
4. Their voting power is reduced to zero 5. They are removed from the active set
of validators

### Slashing Parameters

The slashing mechanism includes configurable parameters: - Slashing rate
(percentage of stake to be slashed) - Minimum slashing transaction fees -
Covenant committee requirements for slashing execution

### Recovery

Once a finality provider is slashed: - The action is permanent and cannot be
reversed - The provider cannot be reactivated - All associated voting power is
permanently removed

### Withdrawing Rewards

When withdrawing rewards, you need to use the Babylon chain's CLI since rewards
are managed by the main chain.

To withdraw your finality provider rewards:

``` babylond tx incentive finality_provider ...  ```

<!-- //this code needs to be updated before further instructions can be provided
-->
