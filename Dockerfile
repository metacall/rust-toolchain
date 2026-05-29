ARG RUST_TOOLCHAIN_IMAGE=debian:trixie-slim

# Build image
FROM ${RUST_TOOLCHAIN_IMAGE} AS build

WORKDIR /workspace

COPY scripts/build.sh /build.sh

RUN /build.sh

# Validate image
FROM ${RUST_TOOLCHAIN_IMAGE} AS validate

WORKDIR /workspace

COPY scripts/validate.sh /validate.sh

RUN /validate.sh
