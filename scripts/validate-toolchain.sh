#!/usr/bin/env bash
set -euxo pipefail

function error() {
    echo "$1"
    exit 1
}

apt update
apt install -y \
    curl \
    build-essential \
    xz-utils \
    cmake \
    ninja-build \
    pkg-config \
    libssl-dev

curl https://sh.rustup.rs -sSf | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"

mkdir -p /rust-dist

for f in \
    /toolchain/dist/rustc-*-x86_64-unknown-linux-gnu.tar.xz \
    /toolchain/dist/rust-std-*.tar.xz \
    /toolchain/dist/cargo-*.tar.xz \
    /toolchain/dist/rustc-dev-*-x86_64-unknown-linux-gnu.tar.xz \
    /toolchain/dist/clippy-*.tar.xz \
    /toolchain/dist/rustfmt-*.tar.xz
do
    tar -xf "$f" -C /rust-dist
done

RUSTC_DIR=$(find /rust-dist -maxdepth 1 -type d -name "rustc-*" ! -name "rustc-dev-*")

"$RUSTC_DIR/install.sh" 
/rust-dist/rust-std-*/install.sh 
/rust-dist/cargo-*/install.sh 
/rust-dist/rustc-dev-*-x86_64-unknown-linux-gnu/install.sh 
/rust-dist/clippy-*/install.sh 
/rust-dist/rustfmt-*/install.sh 

# find /patched-toolchain -name "librustc_driver*.so" 2>/dev/null
# find /patched-toolchain -name "rustc_middle*" 2>/dev/null
# find /patched-toolchain -name "rustc_hir*" 2>/dev/null
# find /patched-toolchain -name "rustc_interface*" 2>/dev/null
# find /patched-toolchain -name "*clippy*"
# find /patched-toolchain -name "*rustfmt*"

# ls /patched-toolchain/lib/rustlib/ 2>/dev/null || echo "no rustlib dir"

rustc -Vv || error "rustc validation failed"

cargo -V || error "cargo validation failed"

cargo clippy --version || error "clippy validation failed"

rustfmt --version || error "rustfmt validation failed"

which rustc || error "rustc not found in path"

which cargo || error "cargo not found in path"

which cargo-clippy || error "clippy not found in path"

which rustfmt || error "rustfmt not found in path"


mkdir /tmp/toolchain-test
cd /tmp/toolchain-test

cargo new hello-world
cd hello-world

cargo build || error "cargo build failed"

cargo clippy -- -D warnings || error "clippy failed"

cargo fmt --check || error "cargo fmt check failed"

cat > src/main.rs <<EOF
fn main() {
    println!("hello");
}
EOF

cargo run || error "cargo run failed"

cargo run