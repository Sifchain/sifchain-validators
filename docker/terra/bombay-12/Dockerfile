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
# Build: Terra
#
FROM golang:1.16 AS terrad

ENV GOBIN=/go/bin
ENV GOPATH=/go
ENV CGO_ENABLED=1
ENV GOOS=linux

WORKDIR /terrad
RUN git clone -b v0.5.5 https://github.com/terra-money/core.git .
RUN go mod download
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

# Copy the compiled binaires over.
COPY --from=cosmovisor /go/bin/cosmovisor /usr/bin/cosmovisor
COPY --from=terrad /go/bin/terrad /usr/bin/terrad
COPY --from=terrad /go/pkg/mod/github.com/\!cosm\!wasm/wasmvm\@v0.16.0/api/libwasmvm.so /usr/lib/libwasmvm.so