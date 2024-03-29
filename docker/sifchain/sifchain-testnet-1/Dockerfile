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
# Build: Sifnode
#
FROM golang:1.16 AS sifnode

ENV GOBIN=/go/bin
ENV GOPATH=/go
ENV CGO_ENABLED=0
ENV GOOS=linux

WORKDIR /sifchain
RUN git clone --branch testnet-0.9.0 https://github.com/Sifchain/sifnode .
RUN go mod download
RUN make install

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
COPY --from=sifnode /go/bin/sifnoded /usr/bin/sifnoded
COPY --from=sifnode /go/bin/sifgen /usr/bin/sifgen
