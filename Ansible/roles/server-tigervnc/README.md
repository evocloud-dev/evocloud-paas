Server with GUI Install
=====

Installs [Server with GUI](https://serverspace.us/support/help/install-tigervnc-server-on-centos-8/)

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
    - server-tigervnc
    - app-vscode
    - app-fail2ban
```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.