Kubelogin
=========
Kubelogin is a kubectl plugin for Kubernetes OpenID Connect (OIDC) authentication, also known as kubectl oidc-login.

Installs [Kubelogin](https://github.com/int128/kubelogin)

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
    - app-kubectl #dependency
    - app-kubelogin

```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.
