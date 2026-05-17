Flux Operator CLI
=========

Installs [Flux Operator CLI](https://github.com/controlplaneio-fluxcd/flux-operator)

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
    - app-flux-operator-cli
```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2026 EvoCloud, Inc.
