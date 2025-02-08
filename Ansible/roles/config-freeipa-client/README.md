Freeipa Client Install and Registration
=====

Installs [Config Freeipa Client](https://computingforgeeks.com/how-to-install-freeipa-client-on-centos-rhel-8/)

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
```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.