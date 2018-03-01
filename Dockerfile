FROM alpine

WORKDIR /builder

# Deps
RUN apk add --update \
    openssh-client \
    docker \
    git \
    make \
    vim \
    bash \

    && \

    mkdir -p /root/.ssh/ \

    && \

    mkdir project \

    && \

    ssh-keyscan github.com >> /root/.ssh/known_hosts

COPY ./build.sh /builder

CMD ["sh", "./build.sh"]
