FROM alpine

WORKDIR /builder

ADD https://storage.googleapis.com/kubernetes-release/release/v1.19.3/bin/linux/amd64/kubectl /usr/local/bin/kubectl

RUN chmod +x /usr/local/bin/kubectl

# Deps
RUN apk add --update \
    openssh-client \
    docker \
    git \
    make \
    vim \
    bash \
    curl \
    ca-certificates \
    py-pip python3-dev libffi-dev openssl-dev gcc libc-dev

RUN pip install docker-compose

# gsutil
RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin

RUN mkdir -p /root/.ssh/ \

    && \

    mkdir project

RUN ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

COPY ./build.sh /builder

CMD ["bash", "./build.sh"]
