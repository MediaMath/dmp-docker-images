FROM python:3.7.0b1-alpine3.7
WORKDIR /app/qds

RUN apk update && \
    apk add python3 docker git openssh bash vim && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    pip3 install docker-compose==1.22.0 awscli==1.16.18 qds-sdk
