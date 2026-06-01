#!/usr/bin/env bash
set -euxo pipefail

docker buildx build \
  --build-arg RUST_TOOLCHAIN_IMAGE="${RUST_TOOLCHAIN_IMAGE}" \
  --load \
  -t metacall/rust-toolchain .
docker run --name metacall-rust-toolchain metacall/rust-toolchain
docker cp metacall-rust-toolchain:/rust-toolchain.tar.gz ./dist/
docker rm metacall-rust-toolchain
