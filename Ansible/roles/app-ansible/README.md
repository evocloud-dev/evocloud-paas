Ansible Binary
=========

[![Build Status](https://github.com/geerlingguy/ansible-role-ansible/workflows/CI/badge.svg?event=push)](https://github.com/geerlingguy/ansible-role-ansible/)


Installs [Ansible](https://docs.ansible.com/ansible/latest/) Configuration Management.


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

License
-------

Powered by [Geant Technology, LLC](https://www.geanttechnology.com)

Author Information
------------------

Arnaud Some <arnaud.some@geanttechnology.net>