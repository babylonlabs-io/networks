## Integrating Bitcoin Staking

> ⚡ Note: Different libraries and software are referenced across this document.
> To avoid linking versions that might be outdated at the time of reading
> we have opted to just link the repositories. Please ensure that
> you utilise the appropriate version for the deployment you are performing.

### 1. Extension Wallet

**Option-1**, be added to a third party’s Bitcoin Staking website as
a wallet for either Bitcoin or Babylon or both.
This requires collaboration with the host of the
website and exposing compatible wallet APIs.
- To be supported in the Babylon hosted staking website as a Bitcoin or Babylon
  wallet, please integrate with the Tomo Wallet Connect
  by following the [docs](https://docs.tomo.inc/tomo-sdk/tomo-connect-sdk-lite).
    - This is the preferred method for wallet integration that will achieve
      the most timely results. The Babylon hosted website will also support
      native wallet integrations for select wallets with long-established
      support.

**Option-2**, host your own Bitcoin staking website
that connects to your extension wallet and retrieves
staking information from a back-end you operate.
- For information about developing/hosting your own Bitcoin staking website, please check
    - our reference web application
      [implementation](https://github.com/babylonlabs-io/simple-staking/).
    - our
      [TypeScript](https://github.com/babylonlabs-io/btc-staking-ts/)
      and [Golang](https://github.com/babylonlabs-io/babylon/tree/main/btcstaking/)
      Bitcoin Staking libraries for creating Bitcoin Staking transactions.
      <!-- TODO: the reference staking library should support the Babylon parts of staking -->
    - our [documentation](https://github.com/babylonlabs-io/babylon/tree/main/x/btcstaking)
      on the flow of Bitcoin Staking transaction creation and submission in
      conjunction with Bitcoin and Babylon blockchains.
      <!-- TODO: these docs are missing -->
- For information about the reference Babylon staking back-end, please read this
  [document](../staking-backend.md)

**Option-3**, develop Bitcoin staking as a feature of your extension wallet,
which connects to either third party APIs
(such as the Babylon [API](https://staking-api.testnet.babylonlabs.io/swagger/index.html)) or a back-end you operate.
- For information about developing your own Bitcoin staking as a feature, please check
    - our reference web application [implementation](https://github.com/babylonlabs-io/simple-staking/tree/main).
    - our
    [TypeScript](https://github.com/babylonlabs-io/btc-staking-ts/)
    and [Golang](https://github.com/babylonlabs-io/babylon/tree/main/btcstaking/)
    Bitcoin Staking libraries.
    - our [documentation](https://github.com/babylonlabs-io/babylon/tree/main/x/btcstaking)
    on the flow of Bitcoin Staking transaction creation and submission in
    conjunction with Bitcoin and Babylon blockchains.
    <!-- TODO: these docs are missing -->
- For information about the reference Babylon staking back-end, please read this
  [document](../staking-backend.md)

### 2. Mobile App Wallet

**Option-1**, embed a third-party Bitcoin staking website to your mobile app
wallet, which interacts with the Bitcoin and Babylon signers inside your wallet via
the application window interface.
To embed on the Babylon hosted staking website, please ensure
that the interface of your mobile wallet (or a wrapper of it)
adheres to the [Injectable Wallet interface]()
<!-- TODO: need a link to the proper docs -->

**Option-2**, host your own Bitcoin staking website that connects to your
extension wallet that retrieves staking information from a back-end you
operate. Then embed your own Bitcoin staking website to your mobile app wallet.
- For information about developing/hosting your own Bitcoin staking website, please check
    - our reference web application
      [implementation](https://github.com/babylonlabs-io/simple-staking/).
    - our
      [TypeScript](https://github.com/babylonlabs-io/btc-staking-ts/)
      and [Golang](https://github.com/babylonlabs-io/babylon/tree/main/btcstaking/)
      Bitcoin Staking libraries for creating Bitcoin Staking transactions.
      <!-- TODO: the reference staking library should support the Babylon parts of staking -->
    - our [documentation](https://github.com/babylonlabs-io/babylon/tree/main/x/btcstaking)
      on the flow of Bitcoin Staking transaction creation and submission in
      conjunction with Bitcoin and Babylon blockchains.
      <!-- TODO: these docs are missing -->
- For information about the reference Babylon staking back-end, please read this
  [document](../staking-backend.md)

**Option-3**, develop Bitcoin staking as a feature of your mobile wallet,
  which connects to either third party APIs
  (such as the Babylon [API](https://staking-api.testnet.babylonlabs.io/swagger/index.html)) or a back-end you operate.
- For information about developing your own Bitcoin staking as a feature, please check
    - our reference web application [implementation](https://github.com/babylonlabs-io/simple-staking/tree/main).
    - our
      [TypeScript](https://github.com/babylonlabs-io/btc-staking-ts/)
      and [Golang](https://github.com/babylonlabs-io/babylon/tree/main/btcstaking/)
      Bitcoin Staking libraries.
    - our [documentation](https://github.com/babylonlabs-io/babylon/tree/main/x/btcstaking)
      on the flow of Bitcoin Staking transaction creation and submission in
      conjunction with Bitcoin and Babylon blockchains.
  <!-- TODO: these docs are missing -->
- For information about the reference Babylon staking back-end, please read this
  [document](../staking-backend.md)

### 3. Hardware Wallet

**Option-1**, develop Bitcoin staking as a feature of your hardware wallet,
which connects to either third party APIs
(such as the Babylon [API](https://staking-api.testnet.babylonlabs.io/swagger/index.html)) or a back-end you operate.
- For information about developing your own Bitcoin staking as a feature, please check
    - our reference web application [implementation](https://github.com/babylonlabs-io/simple-staking/tree/main).
    - our
      [TypeScript](https://github.com/babylonlabs-io/btc-staking-ts/)
      and [Golang](https://github.com/babylonlabs-io/babylon/tree/main/btcstaking/)
      Bitcoin Staking libraries.
    - our [documentation](https://github.com/babylonlabs-io/babylon/tree/main/x/btcstaking)
      on the flow of Bitcoin Staking transaction creation and submission in
      conjunction with Bitcoin and Babylon blockchains.
  <!-- TODO: these docs are missing -->
- For information about the reference Babylon staking back-end, please read this
  [document](../staking-backend.md)

**Option-2**, integrate via a compatible software wallet (extension or mobile)
that is Bitcoin staking enabled.