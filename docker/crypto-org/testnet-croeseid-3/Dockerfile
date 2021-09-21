#
# Build: Cosmovisor
#
FROM golang:1.16 AS cosmovisor

ENV GOBIN=/go/bin
ENV GOPATH=/go
ENV CGO_ENABLED=0
ENV GOOS=linux

RUN go get github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor

#
# Build: Crypto
#
FROM golang:1.16 AS crypto

ENV GOBIN=/go/bin
ENV GOPATH=/go
ENV CGO_ENABLED=0
ENV GOOS=linux

WORKDIR /crypto
RUN git clone --branch v2.0.0-croeseid https://github.com/crypto-org-chain/chain-main .
RUN cd ./third_party/cosmos-sdk && \
    git clone https://github.com/cosmos/cosmos-sdk . && \
    git checkout c4864e9f85011b3e971885ea995a0021c01a885d
RUN cd /crypto
RUN LEDGER_ENABLED=false BUILD_TAGS="--tags=testnet" make build

#
# Main
#
FROM alpine

ENV PACKAGES curl jq bind-tools expect

EXPOSE 1317
EXPOSE 26656
EXPOSE 26657

RUN apk add --update --no-cache $PACKAGES

# Copy the compiled binaires over.
COPY --from=cosmovisor /go/bin/cosmovisor /usr/bin/cosmovisor
COPY --from=crypto /crypto/build/chain-maind /usr/bin/chain-maind
