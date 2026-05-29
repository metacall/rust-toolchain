#!/usr/bin/env bash
set -euxo pipefail

function error() {
	echo "$1"
	exit 1
}

# Uncompress toolchain
tar -xzf /rust-toolchain.tar.gz -C /

# Export bin folder
export PATH="${PATH}:/usr/local/bin"

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

# ls /patched-toolchain/lib/rustlib/ 2>/dev/null || echo "no rustlib dir"

# echo "AFTER TOOLCHAIN INSTALL"

# which rustc
# which cargo

# realpath $(which rustc)
# realpath $(which cargo)

# ls -la /usr/local/bin/rustc
# ls -la /usr/local/bin/cargo

# /usr/local/bin/rustc -Vv
# /usr/local/bin/cargo -V

# rustc -Vv
# cargo -V

# echo $PATH

# rustc -Vv | grep "1.94.0-nightly" || error "wrong rustc version"

# cargo -V | grep "1.94.0" || error "wrong cargo version"

# rustfmt --version | grep "nightly" || error "wrong rustfmt version"

# rustc -Vv || error "rustc validation failed"

# cargo -V || error "cargo validation failed"

# cargo clippy --version || error "clippy validation failed"

# rustfmt --version || error "rustfmt validation failed"

# which rustc | grep "/usr/local/bin" || error "rustc not using installed toolchain"

# which cargo | grep "/usr/local/bin" || error "cargo not using installed toolchain"

# which cargo-clippy | grep "/usr/local/bin" || error "clippy not using installed toolchain"

# which rustfmt | grep "/usr/local/bin" || error "rustfmt not using installed toolchain"


# mkdir /tmp/toolchain-test
# cd /tmp/toolchain-test

# cargo new hello-world
# cd hello-world

# cargo build || error "cargo build failed"

# cargo clippy -- -D warnings || error "clippy failed"

# cargo fmt --check || error "cargo fmt check failed"

# cat > src/main.rs <<EOF
# fn main() {
#	 println!("hello");
# }
# EOF

# cargo run || error "cargo run failed"

# cargo run
