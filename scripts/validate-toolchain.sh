#!/usr/bin/env bash
set -euxo pipefail

function error() {
    echo "$1"
    exit 1
}

if command -v rustc >/dev/null 2>&1; then
    error "rustc already installed before validation"
fi

if command -v cargo >/dev/null 2>&1; then
    error "cargo already installed before validation"
fi

if command -v rustfmt >/dev/null 2>&1; then
    error "rustfmt already installed before validation"
fi

apt update
apt install -y \
    curl \
    build-essential \
    xz-utils \
    cmake \
    ninja-build \
    pkg-config \
    libssl-dev

echo "BEFORE RUSTUP INSTALL"

if command -v rustc >/dev/null 2>&1; then
    which rustc
    rustc -Vv
else
    echo "rustc not installed"
fi

if command -v cargo >/dev/null 2>&1; then
    which cargo
    cargo -V
else
    echo "cargo not installed"
fi

curl https://sh.rustup.rs -sSf | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"

echo "AFTER RUSTUP INSTALL"

which rustc
which cargo

realpath $(which rustc)
realpath $(which cargo)

rustc -Vv
cargo -V

echo $PATH

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

rm -rf /root/.rustup
rm -rf /root/.cargo
hash -r

which rustc
which cargo

rustc -Vv
cargo -V

# find /patched-toolchain -name "librustc_driver*.so" 2>/dev/null
# find /patched-toolchain -name "rustc_middle*" 2>/dev/null
# find /patched-toolchain -name "rustc_hir*" 2>/dev/null
# find /patched-toolchain -name "rustc_interface*" 2>/dev/null
# find /patched-toolchain -name "*clippy*"
# find /patched-toolchain -name "*rustfmt*"

# ls /patched-toolchain/lib/rustlib/ 2>/dev/null || echo "no rustlib dir"

echo "AFTER TOOLCHAIN INSTALL"

which rustc
which cargo

realpath $(which rustc)
realpath $(which cargo)

ls -la /usr/local/bin/rustc
ls -la /usr/local/bin/cargo

/usr/local/bin/rustc -Vv
/usr/local/bin/cargo -V

rustc -Vv
cargo -V

echo $PATH

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