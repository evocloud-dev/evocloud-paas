Nginx Server Proxy Install
=====

Installs [Nginx](https://nginx.org/)

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
    - server-nginx-proxy
```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.
