EvoConnect Enterprise Code Repository Platform
=========
[![travis](https://travis-ci.com/robertdebock/ansible-role-nginx.svg?branch=master)](https://travis-ci.com/robertdebock/ansible-role-nginx)

Installs [EvoCode](https://about.gitlab.com/) Enterprise Code Repository Platform

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
    - webapp-evocode
    - app-fail2ban
```

How to download EvoCode latest offline artifacts
---------------------
There is a script `gitlab-offline-rpm-download` in the files folder in the Ansible role
- Install the script on a VM that has access to the Internet (the deployer VM):
    * ``chmod +x gitlab-offline-rpm-download``
    * ``sudo ./gitlab-offline-rpm-download``
    * ``mkdir gitlab-packages``
    * ``sudo dnf install --downloadonly --downloaddir=./gitlab-packages gitlab-ee``
    * ``sudo tar -cvzf gitlab-packages.tar.gz gitlab-packages/``
- Upload the `gitlab-packages.tar.gz` to the files folder in the Ansible role


License
-------

Powered by [Geant Technology, LLC](https://www.geanttech.com)

Author Information
------------------

Arnaud Some <arnaud.some@geanttech.com>