#
# Build: Hermes
#
FROM rust:1.54 AS hermes

WORKDIR /hermes

RUN git clone -b v0.7.3 https://github.com/informalsystems/ibc-rs.git .
RUN cargo clean && \
    cargo build -vv --release

#
# Main
#
FROM debian:buster-slim

RUN apt update && \
    apt install openssl jq -y

COPY --from=hermes /hermes/target/release/hermes /usr/bin/hermes
