## 👁️ Overview

This section contains code for deploying infrastructure resources on Google Cloud Compute (GCP).

## ☑️ Build Workstation Requirements

- A Linux or MacOS based operating system
- A container runtime environment (Docker, or Podman, or Containerd)
- Generate ssh keys which will be used to login to the compute instances
  * ``ssh-keygen -t rsa -f ~/.ssh/gcp-evocloud -C mlkroot -b 2048``

## ✅ GCP Requirements

- Create a Google Cloud Account
- Request quota increase for:
  - Persistent Disk SSD: at least 2TB
  - VM instances: at least 25
- Create a project (record the project id, we will need it later)
- Create a service account and assign it the following roles:
  * Compute Instance Admin (v1)
  * Compute Network Admin
  * Compute Security Admin
  * Compute Storage Admin
  * DNS Administrator
  * Kubernetes Engine Admin
  * Service Account User
  * Storage Admin
- Still in the service account creation tab:
  * Select the `Keys` tab > then select `Add key` > then click on `Create new key` > select `JSON` > click on `Create`. 
  * Save the Downloaded Key in a secure location. 
- Create two Google Cloud Storage Buckets:
  * One storage bucket for saving Automation state
  * And the other for storing the image artifacts
    * Upload the following Talos image into the image artifacts bucket: ``wget https://factory.talos.dev/image/96f8c146a67c80daad900d3fc1a6976fe11062321eee9ab6ae2a6aea88b2d26e/v1.11.6/gcp-amd64.raw.tar.gz`` 

## ⛏️ Build Process

- On the build workstation, create the following directory structure:
``mkdir -p /tmp/deployer-mount/gcp``

- Get the following files into that directory:
```
cd /tmp/deployer-mount/gcp
wget https://raw.githubusercontent.com/evocloud-dev/evocloud-paas/refs/heads/main/Terraform/gcp/deployment/root.hcl
cp ~/.ssh/gcp-evocloud.pem ~/.ssh/gcp-evocloud.pub ./
touch ansible-vault-pass.txt
touch secret-store.yml 
cp ~/<gcp-credentials>.json ./ #(Get the GCP service account key downloaded earlier into here) 
```

- Make the following configuration edits to match your environment and your deployment requirements:
``vim root.hcl`` # This the Platform single configuration file where you can customize it to your liking
``vim ansible-vault-pass.txt`` # This is where you set the ansible-vault password. After the deployment you can remove that file for security reasons.
``vim secret-store.yml`` # This is where you store the encrypted ansible-vault content, containing default application passwords.

- Now we can start the EvoCloud Platform buildout:
To show the list of available commands run
```
docker run --rm -d --name evo-deployer \
  -v /tmp/deployer-mount:/mnt \
  -e MNTDIR=/mnt -e KEYFILE=my_GCP_CREDS.json \
  ghcr.io/evocloud-dev/evocloud-oci/evo-deployer:0.1.0 list && \
  docker logs -f evo-deployer
```
Any of the build command options have takes care of dependency resolution by default. So in the following example let's build evo-cluster-std
```
docker run --rm -d --name evo-deployer \
  -v /tmp/deployer-mount:/mnt \
  -e MNTDIR=/mnt -e KEYFILE=my_GCP_CREDS.json \
  ghcr.io/evocloud-dev/evocloud-oci/evo-deployer:0.1.0 gcp:build-evo-cluster-std && \
  docker logs -f evo-deployer
```
After the build is complete you can head over to the GCP web UI and see the resources that are created.

We can also use the destroy command to delete the resources if we no longer need them. So in the following example let's destroy the evo-cluster-std
```
docker run --rm -d --name evo-deployer \
  -v /tmp/deployer-mount:/mnt \
  -e MNTDIR=/mnt -e KEYFILE=my_GCP_CREDS.json \
  ghcr.io/evocloud-dev/evocloud-oci/evo-deployer:0.1.0 gcp:destroy-evo-cluster-std && \
  docker logs -f evo-deployer
```