HAProxy Loadbalancer Server  Install
=====

Installs [HAProxy Loadbalancer ](https://www.haproxy.org/)

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
    - server-haproxy-lb
    - app-fail2ban
```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.
