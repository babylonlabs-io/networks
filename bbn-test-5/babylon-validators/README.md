# Babylon Validator Setup

Before setting up a validator, you'll need:
1. A fully synced Babylon node. For node setup instructions, see our 
[Node Setup Guide](../babylon-node/README.md)
2. Sufficient BBN tokens, which are included in the funding section in the 
[Node Setup Guide](../babylon-node/README.md)

## System Requirements

Recommended specifications for running a Babylon validator node:
- CPU: Quad Core AMD/Intel (amd64)
- RAM: 32GB
- Storage: 2TB NVMe
- Network: 100MBps bidirectional

>Note: These are reference specifications for a production validator. 
>Requirements may vary based on network activity and your operational needs.

## Creating Validator

Unlike traditional Cosmos SDK chains, Babylon uses a specialized validator
creation process that integrates with its checkpointing system. The creation
process requires your previously generated BLS key, which should be located at
`~/.babylond/config/priv_validator_key.json`.

To create your validator, run the following command:

```shell 
babylond tx checkpointing create-validator \
./dir/<path>/babylond/config/priv_validator_key.json \
--chain-id bbn-test-5 \
--gas "auto" \
--gas-adjustment 1.5 \
--gas-prices "0.005ubbn" \
--from <your-key-name>
```

Upon successful creation, you'll receive a transaction hash and your validator
operator address 
(e.g., `bbnvaloper12k7w0mtdqp5yff8hr9gj6xe3uq7hnfhguqyqjg`).

### Verifying Validator Setup

1. First, confirm your validator operator address: 

```shell 
babylond keys show <address or name> -a --bech val
 ```

2. Then, inspect your validator's details: 

```shell 
babylond query staking validator <validator-operator-address>
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
    moniker: "node0" 
    website: "https://myweb.site" 
    security_contact: "node0@gmail.com"
  status: 1 tokens: "100"
```

### Understanding Validator Status

Your validator enters the active set based on two conditions: 1. The completion
of the current epoch (a network-wide time period for coordinating activities) 2.
Having sufficient stake to qualify for the active set

When active, your status will show as `BOND_STATUS_BONDED`.

### Managing Your Validator

For delegation operations (`delegate`, `redelegate`, `unbond`, `cancel-unbond`),
you must use the wrapped messages in the checkpointing and epoching modules.
This is because standard staking module messages are disabled in Babylon.

For detailed information about these operations, visit our
[documentation](https://docs.babylonlabs.io/docs/developer-guides/modules/epoching#delaying-wrapped-messages-to-the-end-of-epochs).

Congratulations! Your validator is now part of the Babylon network. Remember to
monitor your validator's performance and maintain good uptime to avoid
penalties.
