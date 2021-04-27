FROM ubuntu:20.04 as base
ENV YQ_VERSION=3.3.2
ENV COMPOSE_VERSION=1.29.1
ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKERVERSION=19.03.9
ENV HELM_VERSION=3.2.4
ENV TRIVYVERSION=0.13.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends git curl \
    uuid \
    jq \
    ca-certificates \
    openssh-client \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Download Trivy
RUN curl -sSLO https://github.com/aquasecurity/trivy/releases/download/v${TRIVYVERSION}/trivy_${TRIVYVERSION}_Linux-64bit.tar.gz \
  && tar xzvf trivy_${TRIVYVERSION}_Linux-64bit.tar.gz \
    -C /bin/ trivy \
  && rm trivy_${TRIVYVERSION}_Linux-64bit.tar.gz
  

RUN curl -sSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz \
  && tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 \
                 -C /bin docker/docker \
  && rm docker-${DOCKERVERSION}.tgz

RUN curl -sSLO https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz \
  && tar xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz --strip 1 \
                 -C /bin/ linux-amd64/helm \
  && rm helm-v${HELM_VERSION}-linux-amd64.tar.gz

RUN curl -ksSL -o /bin/yq https://github.com/mikefarah/yq/releases/download/$YQ_VERSION/yq_linux_amd64
RUN curl -ksSL https://github.com/docker/compose/releases/download/$COMPOSE_VERSION/docker-compose-Linux-x86_64 -o /bin/docker-compose

RUN helm plugin install https://github.com/chartmuseum/helm-push.git
RUN chmod +x /bin/docker-compose
RUN chmod +x /bin/yq
COPY bin /usr/local/bin

