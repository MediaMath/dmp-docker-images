FROM python:3.7.0b1-alpine3.7
WORKDIR /app/qds

RUN apk update && \
    apk add python3 docker git openssh bash vim curl && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    pip3 install urllib3==1.21.1 docker-compose==1.22.0 awscli==1.16.23 qds-sdk boto3
