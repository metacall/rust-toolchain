# MetaCall Rust Toolchain

This repository is for building Rust for [MetaCall Core](https://github.com/metacall/core) repository.
This is required because after updating from `nightly-2021-12-04` to `nightly-2026-01-15` we found that this PR has been introduced: https://github.com/rust-lang/rust/pull/78201
The Rust compiler is distributed as a set of dynamic libraries and the std, but this PR forces the libraries not to be able to be dynamically loaded.
The only option to allow this is to preload them with `LD_PRELOAD` but this goes against the plugin nature of MetaCall.
This small performance improvement invalidates the use of Rust compiler for embeders, so we are recompiling the full tollchain for our needs by removing that flag.

## Reference

For more information check this article: https://maskray.me/blog/2021-02-14-all-about-thread-local-storage
