#
# Build
#
FROM golang:1.16 AS build

ENV GOBIN=/go/bin
ENV GOPATH=/go
ENV CGO_ENABLED=0
ENV GOOS=linux

WORKDIR /gaia
RUN git clone https://github.com/cosmos/gaia .
RUN go mod download
RUN make install

#
# Main
#
FROM alpine

ENV PACKAGES curl jq bind-tools expect

EXPOSE 26656
EXPOSE 26657

RUN apk add --update --no-cache $PACKAGES

# Copy the compiled binaires over.
COPY --from=build /go/bin/gaiad /usr/bin/gaiad
