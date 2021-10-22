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
# Build: Band
#
FROM ubuntu:18.04 AS band

RUN apt update
RUN apt install wget build-essential git -y

RUN wget https://dl.google.com/go/go1.15.2.linux-amd64.tar.gz
RUN tar -xvf go1.15.2.linux-amd64.tar.gz
RUN mv go /usr/local

ENV GOPATH=$HOME/go
ENV GOROOT=/usr/local/go
ENV GOBIN=$GOPATH/bin
ENV PATH=$PATH:/usr/local/go/bin:$GOBIN

WORKDIR /band
RUN git clone --branch v2.3.0 https://github.com/bandprotocol/chain .
RUN make install

#
# Main
#
FROM ubuntu:18.04

EXPOSE 1317
EXPOSE 26656
EXPOSE 26657

RUN apt update
RUN apt install curl wget vim jq -y

COPY --from=cosmovisor /go/bin/cosmovisor /usr/bin/cosmovisor
COPY --from=band /go/bin/bandd /usr/bin/bandd