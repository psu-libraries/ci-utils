FROM ubuntu:25.04 AS base

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

## Tool versions
ENV YQ_VERSION=v4.48.2
ENV COMPOSE_VERSION=v2.40.3
ENV DOCKER_VERSION=29.0.2
ENV BUILDX_VERSION=v0.30.1
ENV HELM_VERSION=4.0.0
ENV TRIVY_VERSION=0.67.2

## Install base packages
#
# - uuid-runtime provides `uuidgen` (the `uuid` package was invalid)
# - no-install-recommends keeps the image lean
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        uuid-runtime \
        jq \
        ca-certificates \
        openssh-client \
        python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Trivy vulnerability scanner
RUN curl -sSL -o trivy.tar.gz \
        https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz \
    && tar -xzvf trivy.tar.gz trivy -C /usr/local/bin \
    && chmod +x /usr/local/bin/trivy \
    && rm trivy.tar.gz   

# Install the Docker CLI
RUN curl -sSLo docker.tgz \
        https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz \
    && tar -xzvf docker.tgz --strip-components=1 -C /usr/local/bin docker/docker \
    && rm docker.tgz

## Install Docker Buildx plugin
RUN mkdir -p ~/.docker/cli-plugins \
    && curl -sSLo buildx \
        https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64 \
    && chmod +x buildx \
    && mv buildx ~/.docker/cli-plugins/docker-buildx

## Install Helm
RUN curl -sSL -o helm.tar.gz \
        https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && tar -xzvf helm.tar.gz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf helm.tar.gz /tmp/linux-amd64   

## Install yq for YAML/JSON processing
RUN curl -sSL -o /usr/local/bin/yq \
        https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 \
    && chmod +x /usr/local/bin/yq





## Optionally install standalone Compose binary
# Newer Docker releases bundle the `docker compose` subcommand into the CLI.
# If your CI scripts rely on the old `docker-compose` command, uncomment
# the following lines to install it.
# RUN curl -sSL -o /usr/local/bin/docker-compose \
#        https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64 \
#    && chmod +x /usr/local/bin/docker-compose

## Install Helm ChartMuseum push plugin (renamed cm-push)
RUN helm plugin install https://github.com/chartmuseum/helm-push.git

## Copy any custom scripts from the build context
COPY bin/ /usr/local/bin/