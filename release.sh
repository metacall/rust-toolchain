#!/usr/bin/env bash
set -euxo pipefail

docker buildx build \
  --platform "${PLATFORM:-linux/amd64}" \
  --build-arg RUST_TOOLCHAIN_IMAGE="${RUST_TOOLCHAIN_IMAGE}" \
  --load \
  -t metacall/rust-toolchain .
docker run --name metacall-rust-toolchain metacall/rust-toolchain
docker cp metacall-rust-toolchain:/rust-toolchain-runtime.tar.gz ./dist/
docker cp metacall-rust-toolchain:/rust-toolchain-dev.tar.gz ./dist/
docker rm metacall-rust-toolchain
