#
# Build: Cosmovisor
#
FROM golang:1.17 AS cosmovisor

ENV GOBIN=/go/bin
ENV GOPATH=/go
ENV CGO_ENABLED=0
ENV GOOS=linux

RUN go get github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor

#
# Build: Juno
#
FROM golang:1.17 AS juno

RUN apt update
RUN apt install make gcc jq wget build-essential git -y
ENV GOBIN=/go/bin
ENV GOPATH=/go
ENV CGO_ENABLED=0
ENV GOOS=linux

WORKDIR /juno

RUN git clone --branch v1.0.0 https://github.com/CosmosContracts/juno .

RUN make install

#
# Main
#
FROM ubuntu:18.04

EXPOSE 1317
EXPOSE 26656
EXPOSE 26657

RUN apt update
RUN apt install curl wget jq vim -y

COPY --from=cosmovisor /go/bin/cosmovisor /usr/bin/cosmovisor
COPY --from=juno /go/bin/junod /usr/bin/junod
#COPY --from=juno /go/pkg/mod/github.com/\!cosm\!wasm/wasmvm\@v0.13.0/api/libwasmvm.so /usr/lib/libwasmvm.so
