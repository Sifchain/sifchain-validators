#
# Build: Sifnode
#
FROM golang:1.16 AS sifnode

ENV GOBIN=/go/bin
ENV GOPATH=/go
ENV CGO_ENABLED=0
ENV GOOS=linux

WORKDIR /sifchain
RUN git clone --branch master https://github.com/Sifchain/sifnode .
RUN go mod download
RUN make install

#
# Wizard
#
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/src

RUN apt update && \
    apt install make jq less curl unzip gnupg software-properties-common git -y

#
# AWS
#
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
RUN curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x ./aws-iam-authenticator && \
    cp ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

#
# kubectl
#
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#
# Helm
#
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

#
# Terraform
#
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
RUN apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN apt install terraform

#
# Sifnode
#
COPY --from=sifnode /go/bin/sifnoded /usr/bin/sifnoded
COPY --from=sifnode /go/bin/sifgen /usr/bin/sifgen
