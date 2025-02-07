Registers Evocode Runner
=====

Installs [webapp-evocode-runner-registration](https://docs.gitlab.com/ee/tutorials/automate_runner_creation/)

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
    - webapp-evocode-runner-registration
```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.