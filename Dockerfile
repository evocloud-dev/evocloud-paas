LABEL maintainer="maintainers@evocloud.dev"
LABEL evo-deployer="0.1.0"
LABEL release-date=""

# Stage 1: Build Environment
ARG ROCKY_VERSION="9.3"
FROM rockylinux:$ROCKY_VERSION AS build-stage

ARG ANSIBLE_VERSION="2.16.3"
ARG TASKFILE_VERSION="3.43.2"
ARG TERRAFORM_VERSION="1.11.4"
ARG TERRAGRUNT_VERSION="0.77.22"

COPY --from=alpine/terragrunt:$TERRAFORM_VERSION /bin/terraform /usr/local/bin
RUN dnf install -y epel-release && \
    dnf update -y && \
    dnf install -y tar ansible-core openssh && \
    ansible-galaxy collection install ansible.posix && \
    curl -L -k "https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRAGRUNT_VERSION/terragrunt_linux_amd64" > "/usr/local/bin/terragrunt" && \
    curl -L -k "https://github.com/go-task/task/releases/download/v$TASKFILE_VERSION/task_linux_amd64.tar.gz" > "/tmp/task_linux_amd64.tar.gz" && \
    curl -L -k "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz" > "/tmp/google-cloud-cli-linux-x86_64.tar.gz" && \
    tar -xzf /tmp/google-cloud-cli-linux-x86_64.tar.gz -C /opt && \
    tar -xzf /tmp/task_linux_amd64.tar.gz -C /usr/local/bin && \
    chmod u+x /usr/local/bin/terragrunt && \
    chmod u+x /usr/local/bin/task && \
    ln -s /opt/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud


# Stage 2: Runtime Environment \
FROM build-stage AS final-stage

ARG PAAS_VERSION="0.1.0"
ARG HOMEDIR="/opt/EVOCLOUD"
RUN mkdir -p $HOMEDIR/{Keys,Logs} && \
    curl -L -k "https://github.com/evocloud-dev/evocloud-paas/archive/refs/tags/v$PAAS_VERSION.tar.gz" > "/tmp/evocloud.tar.gz" && \
    tar -xzf /tmp/evocloud.tar.gz --strip-components=1 -C $HOMEDIR && \
    mv /tmp/evocloud.tar.gz $HOMEDIR && \
    chmod 0660 $HOMEDIR/Logs && \
    rm -rf /tmp/*

WORKDIR $HOMEDIR
ENTRYPOINT ["task"]
