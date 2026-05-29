#!/usr/bin/env bash
set -euxo pipefail

docker build -t metacall/rust-toolchain .
