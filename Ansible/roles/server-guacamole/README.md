Apache Guacamole Remote Desktop Gateway.
=====

Installs [Guacamole Remote Desktop Gateway](https://guacamole.apache.org/)

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
    - app-dnsmasq #Needed by GCP Compute Instances
    - config-freeipa-client
    - config-freeipa-certs
    - app-openjdk
    - server-tomcat #requires app-openjdk
    - server-guacamole-postgres
    - server-nginx-proxy
    - server-guacamole
```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.
