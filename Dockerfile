ARG RUST_TOOLCHAIN_IMAGE=debian:trixie-slim

# Build image
FROM ${RUST_TOOLCHAIN_IMAGE} AS build

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

COPY scripts/build.sh /build.sh

RUN /build.sh

# Pack image
FROM ${RUST_TOOLCHAIN_IMAGE} AS pack

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

COPY --from=build /workspace/rust/build/dist/ /toolchain/

COPY scripts/pack.sh /pack.sh

RUN /pack.sh

# Validate image
FROM ${RUST_TOOLCHAIN_IMAGE} AS validate

WORKDIR /workspace

COPY --from=pack /rust-toolchain.tar.gz /

COPY scripts/validate.sh /validate.sh

RUN /validate.sh
