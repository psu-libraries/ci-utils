FROM ubuntu:25.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

## Tool versions
ENV YQ_VERSION=v4.48.2
ENV COMPOSE_VERSION=v2.40.3
ENV DOCKER_VERSION=29.0.2
ENV BUILDX_VERSION=v0.30.1
ENV TRIVY_VERSION=0.69.2

## Install base packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        uuid-runtime \
        jq \
        ca-certificates \
        openssh-client \
        python3 \
        tar \
        binutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

## Install Trivy vulnerability scanner
RUN set -eux; \
    tmp="$(mktemp)"; \
    curl --fail --location --silent --show-error \
      --connect-timeout 10 \
      --max-time 300 \
      --retry 5 \
      --retry-delay 2 \
      --retry-all-errors \
      --output "${tmp}" \
      "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"; \
    test -s "${tmp}"; \
    tar -tzf "${tmp}" >/dev/null; \
    tar -xzf "${tmp}" -C /tmp trivy; \
    install -m 0755 /tmp/trivy /usr/local/bin/trivy; \
    # strip debug symbols to reduce image size when possible
    strip --strip-all /usr/local/bin/trivy || true; \
    rm -f "${tmp}" /tmp/trivy

## Install the Docker CLI
RUN set -eux; \
    tmp="$(mktemp)"; \
    curl --fail --location --silent --show-error \
      --connect-timeout 10 \
      --max-time 300 \
      --retry 5 \
      --retry-delay 2 \
      --retry-all-errors \
      --output "${tmp}" \
      "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz"; \
    test -s "${tmp}"; \
    tar -tzf "${tmp}" >/dev/null; \
    tar -xzf "${tmp}" --strip-components=1 -C /usr/local/bin docker/docker; \
    chmod +x /usr/local/bin/docker; \
    # strip the docker binary to reduce size
    strip --strip-all /usr/local/bin/docker || true; \
    rm -f "${tmp}"

## Install Docker Buildx plugin
RUN set -eux; \
    mkdir -p /root/.docker/cli-plugins; \
    tmp="$(mktemp)"; \
    curl --fail --location --silent --show-error \
      --connect-timeout 10 \
      --max-time 300 \
      --retry 5 \
      --retry-delay 2 \
      --retry-all-errors \
      --output "${tmp}" \
      "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64"; \
    test -s "${tmp}"; \
    install -m 0755 "${tmp}" /root/.docker/cli-plugins/docker-buildx; \
    strip --strip-all /root/.docker/cli-plugins/docker-buildx || true; \
    rm -f "${tmp}"

## Install yq for YAML/JSON processing
RUN set -eux; \
    tmp="$(mktemp)"; \
    curl --fail --location --silent --show-error \
      --connect-timeout 10 \
      --max-time 300 \
      --retry 5 \
      --retry-delay 2 \
      --retry-all-errors \
      --output "${tmp}" \
      "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64"; \
    test -s "${tmp}"; \
    install -m 0755 "${tmp}" /usr/local/bin/yq; \
    strip --strip-all /usr/local/bin/yq || true; \
    rm -f "${tmp}"

## Optionally install standalone Compose binary
# RUN set -eux; \
#     tmp="$(mktemp)"; \
#     curl --fail --location --silent --show-error \
#       --connect-timeout 10 \
#       --max-time 300 \
#       --retry 5 \
#       --retry-delay 2 \
#       --retry-all-errors \
#       --output "${tmp}" \
#       "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64"; \
#     test -s "${tmp}"; \
#     install -m 0755 "${tmp}" /usr/local/bin/docker-compose; \
#     rm -f "${tmp}"

## Copy any custom scripts from the build context
COPY bin/ /usr/local/bin/
