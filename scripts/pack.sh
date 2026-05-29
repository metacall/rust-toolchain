#!/usr/bin/env bash
set -euxo pipefail

function error() {
	echo "$1"
	exit 1
}

# Install dependencies
apt update && apt install -y --no-install-recommends \
	curl \
	ca-certificates \
	build-essential \
	xz-utils \
	libssl-dev

# Install rustup
curl -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# Create dist folder
SRC_DIR="/toolchain"
DEST_DIR="/rust-dist"
mkdir -p "$DEST_DIR"
ls -Rla ${SRC_DIR}

# List of components
triplet=$(rustc -vV | grep host | awk '{print $2}')
components=(
	"cargo-nightly-${triplet}"
	"clippy-nightly-${triplet}"
	"rust-analysis-nightly-${triplet}"
	"rust-analyzer-nightly-${triplet}"
	"rust-std-nightly-${triplet}"
	"rustc-nightly-${triplet}"
	"rustc-dev-nightly-${triplet}"
	"rustfmt-nightly-${triplet}"
	"rust-src-nightly"
)

# Uncompress all Rust components
for component in "${components[@]}"; do
	file="${SRC_DIR}/${component}.tar.xz"

	echo "Component ${component}: ${file}"

	if [ ! -f "${file}" ]; then
		error "No tarball found for ${component}"
	fi

	echo "Extracting ${file}"
	tar -xf "${file}" -C "${DEST_DIR}"
done

ls -la "${DEST_DIR}"

# Generate snapshot of install prefix before installing Rust
find /usr/local -type f | sort > /tmp/install-prefix-before.txt
wc -l /tmp/install-prefix-before.txt

# Install Rust components
find "${DEST_DIR}" -type f -name "install.sh" -exec bash -c '
	echo "Installing: $1"
	bash "$1"
' _ {} \;

# Generate snapshot of install prefix after installing Rust
find /usr/local -type f | sort > /tmp/install-prefix-after.txt
wc -l /tmp/install-prefix-after.txt

# Generate diff
comm -13 \
	/tmp/install-prefix-before.txt \
	/tmp/install-prefix-after.txt \
	> /tmp/rust-toolchain.txt

cat /tmp/rust-toolchain.txt

# Generate toolchain file
tar -czf /rust-toolchain.tar.gz -T /tmp/rust-toolchain.txt
