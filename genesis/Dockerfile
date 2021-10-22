#
# Build: Sifnode
#
FROM golang:1.16 AS sifnode

ARG branch

ENV GOBIN=/go/bin
ENV GOPATH=/go
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV BRANCH=$branch

WORKDIR /sifchain
RUN git clone --branch $BRANCH https://github.com/Sifchain/sifnode .
RUN go mod download
RUN make install

#
# Main
#
FROM alpine

ENV PACKAGES curl jq bind-tools expect supervisor

EXPOSE 1317
EXPOSE 9090
EXPOSE 26656
EXPOSE 26657

RUN apk add --update --no-cache $PACKAGES

# Copy the compiled binaires over.
COPY --from=sifnode /go/bin/ebrelayer /usr/bin/ebrelayer
COPY --from=sifnode /go/bin/sifnoded /usr/bin/sifnoded
COPY --from=sifnode /go/bin/sifgen /usr/bin/sifgen
