EvoCode Runner - Task Executor for EvoCode Platform
=========
[![travis](https://travis-ci.com/robertdebock/ansible-role-nginx.svg?branch=master)](https://travis-ci.com/robertdebock/ansible-role-nginx)

Installs [EvoCode Runner](https://about.gitlab.com/) Job Executor for EvoCode Platform

Dependencies
------------

See [meta/main.yml](meta/main.yml)

Role Variables
--------------

All variables which can be overridden are stored in [vars/main.yml](vars/main.yml)

Example Playbook
----------------

```yml
- hosts: servers
  roles:
    - config-freeipa-client
    - config-freeipa-certs
    - webapp-evocode-runner
    - app-fail2ban
```

How to download EvoCode Runner latest offline artifacts
---------------------
Run the following commands:
    * ``mkdir gitlab-runner-packages && gitlab-runner-packages``
    * ``wget https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/binaries/gitlab-runner-linux-amd64``
    * ``wget https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/binaries/gitlab-runner-helper/gitlab-runner-helper.x86_64``
    * ``cd ..``
    * ``sudo tar -cvzf gitlab-runner-packages.tar.gz gitlab-runner-packages/``
- Upload the `gitlab-runner-packages.tar.gz` to the files folder in the Ansible role

How to configure Pipeline Job on Github
---------------------
- **Step 01:** Create a Group > Then Project on Gitlab Server
- **Step 02:** Convert your Google GCP Service Account JSON file into base64 encoding
  - ``cat /path/to/geanttech-evocloud-aa3aa17df584.json | base64``
  - Then copy the base64 encoded value, we will need it in later steps
- **Step 03:** Create a variable entry in Gitlab for the GCP_SA_CREDS (And paste in the base64 encoded value)
  - ``Log into Gitlab as the Admin or Root user``
  - Under Settings > CI/CD > Expand Variables > and Click on Add variable
  - For the Key put `GCP_SA_CREDS` and for the Value, paste in the base64 encoded value
  - Then save!
- **Step 04:** Create your .gitlab-ci.yml file to trigger your first pipeline

License
-------

Powered by [Geant Technology, LLC](https://www.geanttech.com)

Author Information
------------------

Arnaud Some <arnaud.some@geanttech.com>