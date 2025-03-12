SOPS
=========
SOPS is security tool for encrypting secrets in YAML, JSON, ENV, INI and BINARY using AWS KMS, GCP KMS, Azure Key Vault, age, and PGP.

Installs [SOPS](https://github.com/getsops/sops)

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
    - app-sops

```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.
