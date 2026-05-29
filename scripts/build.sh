#!/usr/bin/env bash
set -euxo pipefail

RUST_COMMIT="af302a67fdc508cfd08ee22facb96bcf0e5bf831"

function error() {
	echo "$1"
	exit 1
}

# Install dependencies
apt update
apt install -y --no-install-recommends \
	git \
	curl \
	ca-certificates \
	python3 \
	build-essential \
	cmake \
	ninja-build \
	pkg-config \
	libssl-dev

# Clone Rust
git clone https://github.com/rust-lang/rust.git
cd rust
git checkout ${RUST_COMMIT}

# Define our nightly configuration
cat > config.toml <<EOF
[llvm]
download-ci-llvm = true

[build]
extended = true
docs = false

[rust]
channel = "nightly"
codegen-units = 1
download-rustc = false

[dist]
compression-formats = ["xz"]
compression-profile = "fast"
EOF

# Patch initial-exec flag
grep -R "tls-model=initial-exec" src
sed -i 's/-Ztls-model=initial-exec/-Ztls-model=local-dynamic/g' src/bootstrap/src/bin/rustc.rs

# Validate flag
if grep -R "tls-model=initial-exec" src; then
	error "tls-model patch still present"
fi

# Build Rust
python3 x.py dist
