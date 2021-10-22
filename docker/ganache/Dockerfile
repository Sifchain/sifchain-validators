#
# Ganache
#
FROM node:12-alpine

WORKDIR /app

ARG branch

ENV BRANCH=$branch
ENV PACKAGES curl jq bind-tools git

RUN apk add --update --no-cache $PACKAGES
RUN git clone -b $BRANCH https://github.com/Sifchain/sifnode sifnode

WORKDIR /app/sifnode/smart-contracts

COPY deploy.sh /usr/bin/deploy.sh

RUN npm install -g ganache-cli
