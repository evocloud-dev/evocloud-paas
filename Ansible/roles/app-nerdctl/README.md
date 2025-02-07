NerdCTL
=========

Installs [nerdctl](https://github.com/containerd/nerdctl/)

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
    - app-nerdctl
```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.