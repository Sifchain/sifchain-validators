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
# Build: Injective
#
from alpine as injective
ENV PACKAGES curl jq bind-tools expect unzip wget vim

EXPOSE 1317
EXPOSE 9090
EXPOSE 26656
EXPOSE 26657

RUN apk add --update --no-cache $PACKAGES

WORKDIR /injective


RUN wget https://github.com/InjectiveLabs/injective-chain-releases/releases/download/v1.0.1-1630308393/linux-amd64.zip && \
    unzip linux-amd64.zip && \
    mv injectived peggo injective-exchange /usr/bin

COPY --from=cosmovisor /go/bin/cosmovisor /usr/bin/cosmovisor
