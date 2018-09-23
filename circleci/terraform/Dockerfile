FROM hashicorp/terraform:0.11.8
RUN apk update && \
    apk add python3 docker && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools

ENV SCRIPT_HOME "/opt/circleci/scripts"
ENV ENTRYPOINT "${SCRIPT_HOME}/deploy.sh"


ENTRYPOINT ["/bin/bash", "${ENTRYPOINT}"]