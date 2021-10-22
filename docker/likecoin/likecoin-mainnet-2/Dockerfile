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
# Build: Likecoin
#
FROM golang:1.16 AS likechain

ENV GOBIN=/go/bin
ENV GOPATH=/go
ENV CGO_ENABLED=0
ENV GOOS=linux

WORKDIR /likechain
RUN git clone -b fotan-1 https://github.com/likecoin/likecoin-chain .
RUN go mod download
ARG VERSION="fotan-1"
ARG COMMIT="32056fc4759d276a11180256474cc4ed5e3ed8d4"
RUN go build \
    -ldflags "\
    -X \"github.com/cosmos/cosmos-sdk/version.Name=likecoin-chain\" \
    -X \"github.com/cosmos/cosmos-sdk/version.AppName=liked\" \
    -X \"github.com/cosmos/cosmos-sdk/version.BuildTags=netgo ledger\" \
    -X \"github.com/cosmos/cosmos-sdk/version.Version=${VERSION}\" \
    -X \"github.com/cosmos/cosmos-sdk/version.Commit=${COMMIT}\" \
    " \
    -tags "netgo ledger" \
    -o /go/bin/liked cmd/liked/main.go

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
COPY --from=likechain /go/bin/liked /usr/bin/liked
