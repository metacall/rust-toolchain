#!/usr/bin/env bash
set -euxo pipefail

function error() {
	echo "$1"
	exit 1
}

# Install dependencies
apt update && apt install -y --no-install-recommends \
	gcc \
	libc6-dev \
	libssl-dev

# Uncompress toolchain
tar -xzf /rust-toolchain.tar.gz -C /

# Validate
which rustc
which cargo

rustc -Vv
cargo -V

find /usr/local -name "librustc_driver*.so" 2>/dev/null
find /usr/local -name "rustc_middle*" 2>/dev/null
find /usr/local -name "rustc_hir*" 2>/dev/null
find /usr/local -name "rustc_interface*" 2>/dev/null
find /usr/local -name "*clippy*" 2>/dev/null
find /usr/local -name "*rustfmt*" 2>/dev/null

ls /usr/local/lib/rustlib/ 2>/dev/null

rustc -Vv | grep "1.94.0-nightly" || error "wrong rustc version"
cargo -V | grep "1.94.0" || error "wrong cargo version"
rustfmt --version | grep "nightly" || error "wrong rustfmt version"
rustc -Vv || error "rustc validation failed"
cargo -V || error "cargo validation failed"
cargo clippy --version || error "clippy validation failed"
rustfmt --version || error "rustfmt validation failed"

which rustc | grep "/usr/local/bin" || error "rustc not using installed toolchain"
which cargo | grep "/usr/local/bin" || error "cargo not using installed toolchain"
which cargo-clippy | grep "/usr/local/bin" || error "clippy not using installed toolchain"
which rustfmt | grep "/usr/local/bin" || error "rustfmt not using installed toolchain"

# Compile a program
mkdir /tmp/toolchain-test
cd /tmp/toolchain-test

cargo new hello-world
cd hello-world

cargo build || error "cargo build failed"
cargo clippy -- -D warnings || error "clippy failed"
cargo fmt --check || error "cargo fmt check failed"
cargo run | grep "Hello, world!" || error "cargo run failed"
