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
# Build: Secretd
#
from ubuntu:latest as secretd

EXPOSE 1317
EXPOSE 9090
EXPOSE 26656
EXPOSE 26657

WORKDIR /secretd

RUN apt-get update -y && \
    apt-get install -y curl jq expect unzip wget systemd vim && \
    wget "https://github.com/enigmampc/SecretNetwork/releases/download/v1.0.5/secretnetwork_1.0.5_amd64.deb" && \
    apt install ./secretnetwork_1.0.5_amd64.deb && \
    chmod +x /usr/local/bin/secretd

COPY --from=cosmovisor /go/bin/cosmovisor /usr/bin/cosmovisor
