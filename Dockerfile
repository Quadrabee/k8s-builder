FROM node:14-alpine

WORKDIR /builder

ADD https://storage.googleapis.com/kubernetes-release/release/v1.19.3/bin/linux/amd64/kubectl /usr/local/bin/kubectl

RUN chmod +x /usr/local/bin/kubectl

# Deps
RUN apk add --update \
    openssh-client \
    docker \
    docker-compose \
    git \
    make \
    vim \
    bash \
    gettext \
    curl \
    ca-certificates \
    py-pip python3-dev libffi-dev \
    openssl openssl-dev\
    gcc libc-dev

# .NET deps (for cyclonedx-cli)
RUN apk add bash icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib

# cyclonedex-cli
RUN wget https://github.com/CycloneDX/cyclonedx-cli/releases/download/v0.19.0/cyclonedx-linux-musl-x64 && \
    chmod +x cyclonedx-linux-musl-x64 && \
    mv cyclonedx-linux-musl-x64 /usr/bin/cyclonedx

# gsutil
RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin

# grype & syft
RUN curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin
RUN curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# mustache
RUN npm install -g mustache

RUN mkdir -p /root/.ssh/ \

    && \

    mkdir project

RUN ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

COPY ./build.sh /builder

CMD ["bash", "./build.sh"]
