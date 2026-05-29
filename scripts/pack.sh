#!/usr/bin/env bash
set -euxo pipefail

function error() {
	echo "$1"
	exit 1
}

# # Install dependencies
# apt update && apt install -y --no-install-recommends \
# 	curl \
# 	ca-certificates \
# 	build-essential \
# 	xz-utils \
# 	libssl-dev

# # Install rustup
# curl -sSf https://sh.rustup.rs | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"

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

# which rustc
# which cargo

# rustc -Vv
# cargo -V

# find /patched-toolchain -name "librustc_driver*.so" 2>/dev/null
# find /patched-toolchain -name "rustc_middle*" 2>/dev/null
# find /patched-toolchain -name "rustc_hir*" 2>/dev/null
# find /patched-toolchain -name "rustc_interface*" 2>/dev/null
# find /patched-toolchain -name "*clippy*"
# find /patched-toolchain -name "*rustfmt*"

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
