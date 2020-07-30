FROM ubuntu:20.04
ENV YQ_VERSION=3.3.2
ENV COMPOSE_VERSION=1.26.2

RUN apt-get update \
    && apt-get install -y --no-install-recommends docker git curl python3\
    && rm -rf /var/lib/apt/lists/*

RUN curl -ksSL -o /bin/yq https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_amd64
RUN curl -ksSL https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-Linux-x86_64 -o /bin/docker-compose

RUN chmod +x /bin/docker-compose
RUN chmod +x /bin/yq



