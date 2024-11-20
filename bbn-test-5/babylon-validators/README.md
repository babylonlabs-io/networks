# Babylon Validator Setup

Before setting up a validator, you'll need:
1. A fully synced Babylon node. For node setup instructions, see our 
[Node Setup Guide](../babylon-node/README.md)
2. Sufficient BBN tokens. For instructions on obtaining BBN tokens, see the 
[Get Funds section](../babylon-node/README.md#get-funds) in the Node Setup Guide.

## System Requirements

Recommended specifications for running a Babylon validator node:
- CPU: Quad Core AMD/Intel (amd64)
- RAM: 32GB
- Storage: 2TB NVMe
- Network: 100MBps bidirectional
- Encrypted storage for keys and sensitive data
- Regular system backups (hourly, daily, weekly)
- DDoS protection
- Hardware security modules (HSMs) recommended for key storage

>Note: These are reference specifications for a production validator. 
>Requirements may vary based on network activity and your operational needs.

## Setup the required keys for operating a validator 
### Keys for a CometBFT validator

>Note: if you already have set up a key, you can skip this section.

The validator key is a fundamental component of your validator's identity 
within the Babylon network. This cryptographic key-pair serves multiple critical 
functions: it signs blocks during the consensus process, validates transactions, 
and manages your validator's operations on the network. Creating and securing this 
key is one of the most important steps in setting up your validator.

To generate your validator key, use the following command:

```shell
babylond --keyring-backend test keys add <name> --home <path>
```
In this example, we use `--keyring-backend test`, that specifies 
the usage of the `test` backend which stores the keys unencrypted on disk.

Alternatively, there are three options for the keyring backend:

- `test`: Stores keys unencrypted on disk. It’s meant for testing purposes and 
should never be used in production.
- `file`: Stores encrypted keys on disk, which is a more secure option than test but 
less secure than using the OS keyring.
- `os`: Uses the operating system's native keyring, providing the highest level of 
security by relying on OS-managed encryption and access controls.

The `<name>` specifies a unique identifier for the key.
The `--home` flag specifies the directory where your node files will be stored 
(e.g. `--home ./nodeDir`)

The execution result displays the address of the newly generated key and its 
public key. Following is a sample output for the command:

```shell
- address: bbn1kvajzzn6gtfn2x6ujfvd6q54etzxnqg7pkylk9
  name: <name>
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey",
           key: "Ayau+8f945c1iQp9tfTVaCT5lzhD8n4MRkZNqpoL6Tpo"}'
  type: local
```

Make sure to securely store this information, particularly your address and 
private key details. Losing access to these credentials would mean losing 
control of your validator and any staked funds.

## Keys for a BLS Voting
### What is BLS Voting

Babylon validators are required to participate in
[BLS](https://en.wikipedia.org/wiki/BLS_digital_signature) voting
at the end of each epoch.
The Babylon blockchain defines epochs as a fixed period
within the blockchain, defined or set by a number of blocks,
during which the validator set remains consistent. 
At the end of the epoch,
the validator BLS signatures are aggregated to create a compact checkpoint
that is timestamped on the Bitcoin ledger.
The BLS voting mechanism achieves a significant reduction in the cost of
checkpoints, while the epoching mechanism specifies a defined frequency
for checkpointing in the Bitcoin blockchain.

### Create BLS Key

To generate your BLS key, you'll need to use your validator address from the previous step. 
Run this command:

```shell
babylond create-bls-key <address>
```

Replace `<address>` with your validator address from the earlier keyring 
generation (it should look similar to `bbn1kvajzzn6gtfn2x6ujfvd6q54etzxnqg7pkylk9`). 

The system will automatically:
1. Generate a new BLS key pair
2. Associate it with your validator address
3. Store it in your node's configuration file at 
`~/.<path>/config/priv_validator_key.json`

This key will be used automatically by your validator software when it needs 
to participate in epoch-end signature collection. The BLS signatures help 
create compact, efficient proofs of consensus that can be later timestamped to Bitcoin.

Important: The `priv_validator_key.json` file contains sensitive key material. 
Make sure to backup this file and store it securely, as it's essential for your 
validator's operation and cannot be recovered if lost.

## Prepare Validator Configuration

Create your validator configuration file:

```shell
cat > <path>/config/validator.json << EOF
{
  "pubkey": $(cat pubkey.json),
  "amount": "1000ubbn",
  "moniker": "my-validator",
  "commission-rate": "0.10",
  "commission-max-rate": "0.20",
  "commission-max-change-rate": "0.01",
  "min-self-delegation": "1"
}
EOF
```

This command creates the configuration file with your validator settings:
- `pubkey`: Your validator's public key
- `amount`: Initial self-delegation amount
- `moniker`: Your validator's name
- `commission-rate`: Current commission rate
- `commission-max-rate`: Maximum commission rate
- `commission-max-change-rate`: Maximum daily commission change 
- `min-self-delegation`: Minimum self-delegation amount

> Note: The command will create the file if it doesn't exist. No need for a separate `touch` command.

## Creating Validator

Unlike traditional Cosmos SDK chains that use the `staking` module, 
Babylon uses the `checkpointing` module for validator creation and management.

The creation process requires your previously generated BLS key, 
which should be located at `<path>/config/priv_validator_key.json`, 
where `<path>` is the `--home` directory you specified when setting up your node.

To create your validator, run the following command:

```shell 
babylond tx checkpointing create-validator \
    ./<path>/config/validator.json \
    --chain-id bbn-test-5 \
    --gas "auto" \
    --gas-adjustment 1.5 \
    --gas-prices "0.005ubbn" \
    --from <your-key-name>
```
- `--chain-id`: The network identifier
- `--gas`: Set to "auto" to automatically calculate the gas needed
- `--gas-adjustment`: A multiplier for the estimated gas (1.5 adds 50% extra for safety)
- `--gas-prices`: Transaction fee in ubbn per unit of gas
- `--from`: Your key name or address that will sign and pay for this transaction

Upon successful creation, you'll be asked to approve the transaction. 
Once approved, you'll receive a transaction hash and your validator
operator address 
(e.g., `bbnvaloper1qh8444k43spt6m8ernm8phxr332k85teavxmuq`).

### Verifying Validator Setup

1. First, get your validator's operator address using your Babylon address: 
```shell
babylond keys show <your-key-name> --address --bech val --home <path>--keyring-backend test
```

For example, for the address we used above is `bbn1qh8444k43spt6m8ernm8phxr332k85teavxmuq`, 
the operator address is `bbnvaloper1qh8444k43spt6m8ernm8phxr332k85teavxmuq`. 

2. Then, inspect your validator's details: 

```shell 
babylond query staking validator <validator-operator-address> --home <path>
```

You should see your validator's configuration, including: 

```yaml 
validator:
  commission:
    rates:
      current: "100000000000000000" 
      max: "1000000000000000000" 
      max_change: "10000000000000000"
  description:
    moniker: "my-validator" 
    website: "https://myweb.site" 
    security_contact: "my-validator0@gmail.com"
  status: 1 tokens: "100"
```

### Understanding Validator Status

Your validator enters the active set based on two conditions: 
1. The completion of the current epoch (a network-wide time period for 
coordinating activities) 
2. Having sufficient stake to qualify for the active set.

When active, your status will show as `BOND_STATUS_BONDED`.

### Managing Your Validator

For delegation operations (`delegate`, `redelegate`, `unbond`, `cancel-unbond`),
you must use the wrapped messages in the `checkpointing` and `epoching` modules.
This is because standard staking module messages are disabled in Babylon.

For detailed information about these operations, visit our
[documentation](https://docs.babylonlabs.io/docs/developer-guides/modules/epoching#delaying-wrapped-messages-to-the-end-of-epochs).

## Advanced Security Architecture

Validators should be run with additional security measures:

**Sentry Node Architecture**  
For enhanced security, validators should implement a sentry node architecture. 
This involves deploying sentry nodes as a protective layer around your 
validator node, following the established [Cosmos Sentry Node Architecture](https://forum.cosmos.network/t/sentry-node-architecture-overview/454). 
The sentry nodes act as a buffer between your validator and the public network, 
with a private network maintained between your validator and its sentry nodes. 
This architecture helps protect your validator from DDoS attacks and other 
network-level threats by ensuring your validator only communicates with trusted 
sentry nodes rather than directly with the public network.

## Enhanced Monitoring

In addition to basic node monitoring, validators should:

1. Monitor validator performance metrics
   - Signing performance
   - Missed blocks
   - Voting power changes
   - BLS signing status

2. Set up alerts for:
   - Slashing conditions
   - Validator status changes
   - Network participation metrics
   - System resource thresholds
   
Congratulations! Your validator is now part of the Babylon network. Remember to
monitor your validator's performance and maintain good uptime to avoid
penalties.
