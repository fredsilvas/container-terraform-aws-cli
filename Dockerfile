# Setup build arguments with default versions
ARG AWS_CLI_VERSION=2.1.38
ARG TERRAFORM_VERSION=0.15.0
ARG PYTHON_MAJOR_VERSION=3.7
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
RUN apt-get update && apt-get install -y curl unzip gnupg
RUN apt-get clean && rm -rf /var/lib/apt/lists/* && apt-get autoremove -y

#RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
#RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig
#COPY hashicorp.asc hashicorp.asc
#RUN gpg --import hashicorp.asc
#RUN gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
#RUN grep terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_SHA256SUMS | sha256sum -c -
RUN unzip -j terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip


# Build final image
FROM debian:buster-slim
ARG AWS_CLI_VERSION
ARG PYTHON_MAJOR_VERSION

RUN apt-get update && apt-get install -y curl unzip git jq python3=${PYTHON_MAJOR_VERSION}.3-1 python3-pip=18.1-5 libpython3-dev libpython3.7 --no-install-recommends

RUN pip3 install setuptools wheel pyyaml

RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install && aws --version && rm awscliv2.zip

COPY --from=terraform /terraform /usr/local/bin/terraform
RUN ln -s /usr/lib/x86_64-linux-gnu/libpython3.7m.so.1.0 /usr/local/bin/libpython3.7m.so.1.0

ARG GITLAB_TOKEN_USER_INFRA
ARG GITLAB_SECRET_TOKEN_KEY_INFRA
ARG GITLAB_TOKEN_USER_INFRA_DEVOPS
ARG GITLAB_SECRET_TOKEN_KEY_INFRA_DEVOPS
ARG GITLAB_TOKEN_USER_COMUNICACAO
ARG GITLAB_SECRET_TOKEN_KEY_COMUNICACAO
ARG GITLAB_TOKEN_USER_SISTEMAS
ARG GITLAB_SECRET_TOKEN_KEY_SISTEMAS

RUN git config --global url."https://${GITLAB_TOKEN_USER_INFRA}:${GITLAB_SECRET_TOKEN_KEY_INFRA}@git.ifpr.edu.br/infraestrutura/ifpr".insteadOf https://git.ifpr.edu.br/infraestrutura/ifpr
RUN git config --global url."https://${GITLAB_TOKEN_USER_INFRA_DEVOPS}:${GITLAB_SECRET_TOKEN_KEY_INFRA_DEVOPS}@git.ifpr.edu.br/infraestrutura/ifpr-devops".insteadOf https://git.ifpr.edu.br/infraestrutura/ifpr-devops
RUN git config --global url."https://${GITLAB_TOKEN_USER_COMUNICACAO}:${GITLAB_SECRET_TOKEN_KEY_COMUNICACAO}@git.ifpr.edu.br/comunicacao".insteadOf https://git.ifpr.edu.br/comunicacao
RUN git config --global url."https://${GITLAB_TOKEN_USER_SISTEMAS}:${GITLAB_SECRET_TOKEN_KEY_SISTEMAS}@git.ifpr.edu.br/sistemas-dtic".insteadOf https://git.ifpr.edu.br/sistemas-dtic


WORKDIR /workspace
CMD ["bash"]