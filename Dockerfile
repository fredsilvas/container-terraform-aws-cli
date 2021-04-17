# Setup build arguments with default versions
ARG TERRAFORM_VERSION=0.15.0
ARG AWS_CLI_VERSION=2.1.38
ARG GITLAB_TOKEN_USER_INFRA
ARG GITLAB_SECRET_TOKEN_KEY_INFRA
ARG GITLAB_TOKEN_USER_INFRA_DEVOPS
ARG GITLAB_SECRET_TOKEN_KEY_INFRA_DEVOPS
ARG GITLAB_TOKEN_USER_COMUNICACAO
ARG GITLAB_SECRET_TOKEN_KEY_COMUNICACAO
ARG GITLAB_TOKEN_USER_SISTEMAS
ARG GITLAB_SECRET_TOKEN_KEY_SISTEMAS


# Download Terraform binary
FROM debian:buster-slim as terraform
ARG TERRAFORM_VERSION
RUN apt-get update && apt-get install -y git jq curl unzip --no-install-recommends
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && apt-get autoremove -y

RUN curl -k -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN unzip -j terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip


# Build final image
FROM debian:buster-slim
ARG AWS_CLI_VERSION
RUN apt-get update && apt-get install -y openvpn --no-install-recommends

COPY --from=terraform /usr/bin/git /usr/bin/git
COPY --from=terraform /usr/bin/jq /usr/bin/jq
COPY --from=terraform /usr/bin/curl /usr/bin/curl
COPY --from=terraform /usr/bin/unzip /usr/bin/unzip
COPY --from=terraform /terraform /usr/local/bin/terraform

COPY --from=terraform /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu
COPY --from=terraform /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu

RUN curl -k "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install && aws --version && rm awscliv2.zip && rm -rf /aws

ARG GITLAB_TOKEN_USER_INFRA
ARG GITLAB_SECRET_TOKEN_KEY_INFRA
ARG GITLAB_TOKEN_USER_INFRA_DEVOPS
ARG GITLAB_SECRET_TOKEN_KEY_INFRA_DEVOPS
ARG GITLAB_TOKEN_USER_COMUNICACAO
ARG GITLAB_SECRET_TOKEN_KEY_COMUNICACAO
ARG GITLAB_TOKEN_USER_SISTEMAS
ARG GITLAB_SECRET_TOKEN_KEY_SISTEMAS

RUN git config --global url."https://${GITLAB_TOKEN_USER_INFRA}:${GITLAB_SECRET_TOKEN_KEY_INFRA}@git.ifpr.edu.br/infraestrutura/ifpr".insteadOf https://git.ifpr.edu.br/infraestrutura/ifpr && \
    git config --global url."https://${GITLAB_TOKEN_USER_INFRA_DEVOPS}:${GITLAB_SECRET_TOKEN_KEY_INFRA_DEVOPS}@git.ifpr.edu.br/infraestrutura/ifpr-devops".insteadOf https://git.ifpr.edu.br/infraestrutura/ifpr-devops && \
    git config --global url."https://${GITLAB_TOKEN_USER_COMUNICACAO}:${GITLAB_SECRET_TOKEN_KEY_COMUNICACAO}@git.ifpr.edu.br/comunicacao".insteadOf https://git.ifpr.edu.br/comunicacao && \
    git config --global url."https://${GITLAB_TOKEN_USER_SISTEMAS}:${GITLAB_SECRET_TOKEN_KEY_SISTEMAS}@git.ifpr.edu.br/sistemas-dtic".insteadOf https://git.ifpr.edu.br/sistemas-dtic

RUN rm -rf /var/cache/*
RUN apt-get clean
WORKDIR /workspace
CMD ["bash"]