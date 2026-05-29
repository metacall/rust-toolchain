ARG RUST_TOOLCHAIN_IMAGE=debian:trixie-slim

# Build image
FROM ${RUST_TOOLCHAIN_IMAGE} AS build

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

COPY scripts/build.sh /build.sh

# TODO:
RUN /build.sh || true

# Pack image
FROM ${RUST_TOOLCHAIN_IMAGE} AS pack

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

COPY --from=build /workspace/rust/build/dist/ /toolchain/

RUN ls -Rla /toolchain

# TODO: Remove this
RUN apt update && apt install -y --no-install-recommends \
	curl \
	ca-certificates \
	build-essential \
	xz-utils \
	libssl-dev \
    && curl -sSf https://sh.rustup.rs | sh -s -- -y

COPY scripts/pack.sh /pack.sh

RUN /pack.sh

# Validate image
FROM ${RUST_TOOLCHAIN_IMAGE} AS validate

WORKDIR /workspace

COPY --from=build /rust-toolchain.tar.gz /

COPY scripts/validate.sh /validate.sh

RUN /validate.sh
