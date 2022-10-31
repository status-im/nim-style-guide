## Development setup `[setup]`

As a new Nimbus developer there is a lot to learn.

Are you already familiar with crypto? If so, [start here](#development)

Are you new to the crypto space? If so, [start here](#crypto)

## Crypto

At nimbus we are building a validator client for the "[Beacon Chain](https://medium.com/poloniex/what-is-ethereums-beacon-chain-fcac348210d7)".

There exists a ["Proof of Work"](https://medium.com/coinmonks/simply-explained-why-is-proof-of-work-required-in-bitcoin-611b143fc3e0)" repository, the [nimbus-eth1](https://github.com/status-im/nimbus-eth1) repo.

And we also have one for the ["Proof of Stake"](https://github.com/status-im/nimbus-eth2) and other novel features.

These two applications are linked, however it doesn't only have to be Nimbus which is part of this linking.

Ethereum nodes should be independant of architecture. We can build one in Nim or JS and they should respond the same way to requests, allowing them to be swapped out on-demand. This also allows new technologies and features to arrive more promptly. (See nimbus-eth2)

[Here's a small intro](https://medium.com/@hernackikacper/beacon-chain-how-it-will-change-blockchain-technology-48e56fa93c90) on how the Beacon chain (V2) interacts with the Mainnet (v1).

### Forks `[setup.buzzwords.forks]`

- Phase0
- Altair
- Bellatrix
- Capella

The above are all names of Beacon Chain "forks", where we add new features and improve the software. This is not only a Nimbus terminology but rather a full Ethereum terminology. You can find more info by looking [directly at the spec](https://github.com/ethereum/consensus-specs/tree/dev/specs).

In the above link you should find all current Buzzwords for the names of the Beacon Chain forks. If you don't see the word there, then it's probably something else and it's nice to ask about it.

### Development `[setup.buzzwords.development]`
