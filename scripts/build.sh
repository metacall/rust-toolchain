#!/usr/bin/env bash
set -euxo pipefail

function error() {
    echo "$1"
    exit 1
}

RUST_COMMIT="af302a67fdc508cfd08ee22facb96bcf0e5bf831"

apt update
apt install -y \
    git \
    curl \
    python3 \
    build-essential \
    cmake \
    ninja-build \
    pkg-config \
    libssl-dev 

git clone https://github.com/rust-lang/rust.git
cd rust

git checkout ${RUST_COMMIT}

cat > config.toml <<EOF
[llvm]
download-ci-llvm = true

[build]
extended = true

[rust]
channel = "nightly"
codegen-units = 1
download-rustc = false

[dist]
compression-formats = ["xz"]
compression-profile = "fast"
EOF

grep -R "tls-model=initial-exec" src

sed -i '/tls-model=initial-exec/d' src/bootstrap/src/bin/rustc.rs

if grep -R "tls-model=initial-exec" src; then
    error "tls-model patch still present"
fi

python3 x.py dist