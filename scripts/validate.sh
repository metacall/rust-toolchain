#!/usr/bin/env bash
set -euxo pipefail

function error() {
	echo "$1"
	exit 1
}

# Runtime validation check
function validate_runtime() {
	rustc -Vv | grep "1.94.0-nightly"|| error "rustc not found in runtime tarball"
	cargo -V  | grep "1.94.0" || error "cargo not found in runtime tarball"

	which rustc || error "rustc not found in runtime tarball"
	which cargo || error "cargo not found in runtime tarball"

	rm -rf /tmp/runtime-test
	mkdir -p /tmp/runtime-test
	cd /tmp/runtime-test

	cargo new hello-world
	cd hello-world
	cargo build || error "the program couldn't build"
	cargo run | grep "Hello, world!" || error "the program couldn't run"
}

# Development validation check
function validate_dev() {
	cargo clippy --version || error "clippy not found in dev tarball"
	rustfmt --version || error "rustfmt not found in dev tarball"

	which cargo-clippy | grep "/usr/local/bin"|| error "clippy not found in dev tarball"
	which rustfmt | grep "/usr/local/bin" || error "rustfmt not found in dev tarball"

	cargo clippy -- -D warnings || error "clippy failed"
	cargo fmt --check || error "cargo fmt check failed"
}

# Install dependencies
apt update && apt install -y --no-install-recommends \
	gcc \
	libc6-dev \
	libssl-dev

# Uncompress toolchain runtime tarball
tar -xzf /rust-toolchain-runtime.tar.gz -C /
validate_runtime

# Uncompress toolchain dev tarball
tar -xzf /rust-toolchain-dev.tar.gz -C /
validate_dev
