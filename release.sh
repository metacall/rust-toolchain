#!/usr/bin/env bash
set -euxo pipefail

docker build -t metacall/rust-toolchain .
docker run --name metacall-rust-toolchain metacall/rust-toolchain
docker cp metacall-rust-toolchain:/rust-toolchain.tar.gz ./dist/
