
## Overview of Covenant Emulator

Covenant emulator is a daemon program run by every member of the covenant
committee of the BTC staking protocol. The role of the covenant committee is to
protect PoS systems against attacks from the BTC stakers and validators. It
achieves this by representing itself as an M-out-of-N multi-signature that
co-signs BTC transactions with the BTC staker.

More specifically, through co-signing, the covenant committee enforces the
following three spending rules of the staked bitcoins, the equivalence of which
is common for PoS systems:

1. If the staker is malicious and gets slashed, the percentage of the slashed
bitcoins must satisfy the protocol's fractional slashing percentage.  
2. If the staker is malicious and gets slashed, the destination address of the
slashed bitcoins must be the unique slashing address specified by the protocol,
not any other address.  
3. when the staker unbonds, the unbonding time must be no shorter than the
protocol's minimum stake unbonding time.

Besides enforcing rules via co-signing, the covenant committee has no other duty
or power. If it has a dishonest super majority, then

The Covenant Committee has the following capabilities:
    - refuse to co-sign, so that no bitcoin holders can stake. In this case, no
    bitcoin will be locked because the protocol requires the committee to
    pre-sign all the transactions, and - collude with the stakers, so that the
    staker can dodge slashing.

However, the Committee cannot:
    - steal the staker’s bitcoins, because all the spending transactions require
    the staker's signature; - slash the staker’s bitcoins by itself, because
    slashing requires the secret key of the finality provider, which the
    covenant committee does not know in advance, and - prevent the staker from
    unbonding or withdrawing their bitcoins, again, because the protocol
    requires the committee to pre-sign all the transactions.


In other words, there is no way the committee can act against the stakers,
except rejecting their staking requests. Furthermore, the dishonest actions of
the covenant committee can be contained by 1) including the staker’s
counterparty in the committee, such as the PoS system’s foundation, or 2)
implementing a governance proposal to re-elect the committee.

This rule-enforcing committee is necessary for now because the current BTC
protocol does not have the programmability needed to enforce these rules by
code. This committee can be dimissed once such programmability becomes
available, e.g., if BTC's covenant
proposal [BIP-119](https://github.com/bitcoin/bips/blob/master/bip-0119.mediawiki) is
merged.

Covenant emulation committee members are defined in the Babylon parameters and
their public keys are recorded in the genesis file of the Babylon chain.
Changing the covenant committee requires a [governance
proposal](https://docs.cosmos.network/v0.50/build/modules/gov). Each committee
member runs the `covd` daemon (short for `covenant-emulator-daemon`), which
constantly monitors staking requests on the Babylon chain, verifies the validity
of the Bitcoin transactions that are involved with them, and sends the necessary
signatures if verification is passed. The staking requests can only become
active and receive voting power if a sufficient quorum of covenant committee
members have verified the validity of the transactions and sent corresponding
signatures.

Upon a pending staking request being found, the covenant emulation daemon
(`covd`), validates it against the spending rules defined in [Staking Script
specification](https://github.com/babylonlabs-io/babylon/blob/dev/docs/staking-script.md),
and sends three types of signatures to the Babylon chain:

1. **Slashing signature**. This signature is an [adaptor
signature](https://bitcoinops.org/en/topics/adaptor-signatures/), which signs
over the slashing path of the staking transaction. Due to
the [recoverability](https://github.com/LLFourn/one-time-VES/blob/master/main.pdf) of
the adaptor signature, it also prevents a malicious finality provider from
irrationally slashing delegations.  2. **Unbonding signature**. This signature
is a [Schnorr signature](https://en.wikipedia.org/wiki/Schnorr_signature), which
is needed for the staker to unlock their funds before the original staking time
lock expires (on-demand unbonding).  3. **Unbonding slashing signature**. This
signature is also an adaptor signature, which has similar usage to
the **slashing signature** but signs over the slashing path of the unbonding
transaction.

## Install Covenant Emulator

Download [Golang 1.21](https://go.dev/dl) 

Using the go version 1.21.x (where x is any patch version like 1.21.0, 1.21.1,
etc.) Once installed run:

```shell 
go version 
```

Subsequently clone the covenant
[repository](https://github.com/babylonlabs-io/covenant-emulator).

```shell 
git clone git@github.com:babylonlabs-io/covenant-emulator.git 
```

Once the `babylon` repository is downloaded then checkout the corresponding tag
for `bbn-testnet-5`.

``` shell 
git checkout <tag> 
```

You should now have the repository on your machine. Next navigate into the
repository you just cloned and run the following:

```shell 
make install 
```

This command does the following: - Builds the daemon - Compile all Go packages
in the project - Installs the binary - Makes the `babylond` command globally
accessible from your terminal - Build and install the binaries to `$GOPATH/bin`:

If your shell cannot find the installed binaries, make sure `$GOPATH/bin` is in
the `$PATH` of your shell. The following command should help this issue.

```shell 
export PATH=$HOME/go/bin:$PATH 
echo 'export PATH=$HOME/go/bin:$PATH' >> ~/.profile 
```

And should return something such as below:

```shell 
mkdir -p /Users/samricotta/code/covenant-emulator/build/ go install
-mod=readonly --tags "" --ldflags ''  ./... 
```

Now it has successfully compiled lets check, with the following command:

```shell 
covd 
```

Which will give us a list of available actions.

```shell 
COMMANDS:
   start           Start the Covenant Emulator Daemon 
   init            Initialize a covenant home directory. 
   create-key, ck  Create a Covenant account in the keyring. 
   help, h         Shows a list of commands or help for one command
``` 

### Setup home directory and configure

Next we initialize the node and home directory. It should generate all of the
necessary files such as `covd.config`, which will live in the `<path>` that you
set for the `--home`with the below command.

```shell 
covd init --home <path> 
```

After initialization, the home directory will have the following structure

```shell 
$ ls <path>
  ├── covd.conf # Covd-specific configuration file.  ├── logs      # Covd logs
```

Next, we will configure the `covd.conf` file to set up the connection parameters
for the Babylon chain and other covenant emulator settings.

```
# The interval between each query for pending BTC delegations
QueryInterval = 15s

# The maximum number of delegations that the covd processes each time
DelegationLimit = 100

# Bitcoin network to run on BitcoinNetwork = simnet

# Babylon specific parameters

# Babylon chain ID ChainID = bbn-test-5

# Babylon node RPC endpoint RPCAddr =
https://rpc-euphrates.devnet.babylonlabs.io:443

# Babylon node gRPC endpoint GRPCAddr =
https://rpc-euphrates.devnet.babylonlabs.io:443

# Name of the key in the keyring to use for signing transactions Key =
covenant-key

# Type of keyring to use, # supported backends -
(os|file|kwallet|pass|test|memory) # ref
https://docs.cosmos.network/v0.46/run-node/keyring.html#available-backends-for-the-keyring
KeyringBackend = test

``` 

### Generate key pairs

The covenant emulator daemon requires the existence of a keyring that signs
signatures and interacts with Babylon. Use the following command to generate the
key:

```shell 
covd create-key --key-name covenant-key --chain-id bbn-test-5 --home <path>
```

If successful it will output the below:

```shell 
{
    "name": "covenant-key",
	"public-key":
	"829efe41163002144df5dce3c681f741a85cf4742490686c281bfdea94c0e162"
} ```

After executing the above command, the key name will be saved in the config file
created in the `--home` directory within `keyring-test`

>Note: The `public-key` in the output should be used as one of the inputs of the
genesis of the Babylon chain.

>This key will be used to pay for the fees due to the daemon submitting
signatures to Babylon.  

### Start the daemon

You can start the covenant emulator daemon using the following command:

```shell 
covd start --home <path> 
```

The daemon should be running as below:

```shell 
covd start --home ./covd 
```

```shell 
2024-11-12T19:45:25.907088Z     info    Starting Covenant Emulator
2024-11-12T19:45:25.907096Z     info    Starting Prometheus server
{"address": "127.0.0.1:2112"} 2024-11-12T19:45:25.907141Z     info    Covenant
Emulator Daemon is fully active!  
```
