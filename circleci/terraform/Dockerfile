FROM golang:alpine
RUN apk update && \
    apk add python3 docker git opensh bash && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    pip3 install docker-compose==1.22.0 awscli==1.16.18
ENV SCRIPT_HOME "/opt/circleci/scripts"

RUN mkdir -p $SCRIPT_HOME
COPY ./scripts $SCRIPT_HOME
RUN chmod 555 $SCRIPT_HOME/*.sh
