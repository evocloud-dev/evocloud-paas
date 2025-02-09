EvoHarbor - Task Executor for EvoHarbor Platform
=========
[![travis](https://travis-ci.com/robertdebock/ansible-role-nginx.svg?branch=master)](https://travis-ci.com/robertdebock/ansible-role-nginx)

Installs [EvoHarbor](https://goharbor.io/docs/2.12.0//) Job Executor for EvoHarbor Platform

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
    - app-dnsmasq
    - config-freeipa-client
    - config-freeipa-certs
    - webapp-evoharbor
    - app-fail2ban
```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.