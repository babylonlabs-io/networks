# New ${nickname} Finality Provider

Follow the finality provider information registry
[guide](https://github.com/babylonlabs-io/networks/blob/ef18868512b0b9c823c653cdabc975f88b6fc7a2/bbn-1/finality-providers/README.md#L1)
instructions to generate information.

## Checklist

- [ ] [Create EOTS Key](https://github.com/babylonlabs-io/networks/blob/ef18868512b0b9c823c653cdabc975f88b6fc7a2/bbn-1/finality-providers/README.md#L154)
- [ ] Backup Mnemonic
- [ ] Generate Finality Provider Information
- [ ] Input the information into a file under `bbn-1/finality-providers/registry/{nickname}.json`
- [ ] [Sign the file](https://github.com/babylonlabs-io/networks/blob/ef18868512b0b9c823c653cdabc975f88b6fc7a2/bbn-1/finality-providers/README.md#L271)
- [ ] Input the signature into a file under `bbn-1/finality-providers/sigs/{nickname}.sig`
- [ ] Accept [terms and conditions](https://link-to-terms.com)

> [!CAUTION]
> The loss of the (generated keys + mnemonic) makes the finality provider
useless and unable to provide finality, which would lead to no transition to
later phases of the Babylon networks.
