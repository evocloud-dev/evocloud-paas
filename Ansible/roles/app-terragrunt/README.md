Terragrunt Binary
=====

[![Build Status](https://travis-ci.org/andrewrothstein/ansible-terragrunt.svg?branch=master)](https://travis-ci.org/andrewrothstein/ansible-terragrunt)


Installs [Terrgrunt Binary](https://github.com/gruntwork-io/terragrunt/)

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
    - app-terragrunt
```

License
-------

Powered by [Geant Technology, LLC](https://www.geanttech.com)

Author Information
------------------

Arnaud Some <arnaud.some@geanttech.com>