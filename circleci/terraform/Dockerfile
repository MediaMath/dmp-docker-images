FROM golang:alpine

ENV SCRIPT_HOME "/opt/circleci/scripts"
ENV TERRAFORM_VERSION=0.10.0
ENV TF_DEV=true
ENV TF_RELEASE=true

RUN apk update && \
    apk add python3 docker git openssh bash && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    pip3 install docker-compose==1.22.0 awscli==1.16.18
WORKDIR $GOPATH/src/github.com/hashicorp/terraform
RUN git clone https://github.com/hashicorp/terraform.git ./ && \
    git checkout v${TERRAFORM_VERSION} && \
    /bin/bash scripts/build.sh
RUN mkdir -p $SCRIPT_HOME
COPY ./scripts $SCRIPT_HOME
RUN chmod 555 $SCRIPT_HOME/*.sh
