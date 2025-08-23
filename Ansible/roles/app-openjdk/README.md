OpenJDK or OpenJRE
=========
[![Build Status](https://travis-ci.org/andrewrothstein/ansible-openjdk.svg?branch=master)](https://travis-ci.org/andrewrothstein/ansible-openjdk)

Installs [OpenJDK or OpenJRE](https://adoptopenjdk.net/)

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
    - app-openjdk
```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.