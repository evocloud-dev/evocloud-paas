Ansible Binary
=========

[![Build Status](https://github.com/geerlingguy/ansible-role-ansible/workflows/CI/badge.svg?event=push)](https://github.com/geerlingguy/ansible-role-ansible/)


Installs [Ansible](https://docs.ansible.com/ansible/latest/) Configuration Management Tool.



Dependencies
------------

See [meta/main.yml](meta/main.yml)

Role Variables
--------------

All variables which can be overwritten are stored in [vars/main.yml](vars/main.yml)

Example Playbook
----------------

```yml
- hosts: servers
  roles:
    - app-ansible
```

Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.
