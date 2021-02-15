# Introduction

[Online version](https://status-im.github.io/nim-style-guide/)

An ever evolving collection of conventions, idioms and tricks that reflects the experience of developing a production-grade application in [Nim](https://nim-lang.org) with a small team of developers.

## Build and publish

The style guide is built using [mdBook](https://github.com/rust-lang/mdBook), and published to gh-pages using a github action.

```bash
# Install tooling
cargo install mdbook mdbook-toc mdbook-open-on-gh

# Edit book and view through local browser
mdbook serve
```

## Contributing

We welcome contributions to the style guide as long as they match the strict security requirements Status places on Nim code. As with any style guide, some of it comes down to taste and we might reject them based on consistency or whim.
