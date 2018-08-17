FROM alpine

WORKDIR /builder

ADD https://storage.googleapis.com/kubernetes-release/release/v1.6.4/bin/linux/amd64/kubectl /usr/local/bin/kubectl

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
    ca-certificates

RUN mkdir -p /root/.ssh/ \

    && \

    mkdir project

RUN ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    ssh-keyscan q8s.quadrabee.com >> /root/.ssh/known_hosts && \
    ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

COPY ./build.sh /builder

CMD ["bash", "./build.sh"]
