Enterprise IdM Server Replica
=====

Installs [Server Freeipa Replica](https://www.linuxsysadmins.com/setup-a-freeipa-or-idm-replica/)

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
    - server-freeipa-replica
    - app-fail2ban
```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.