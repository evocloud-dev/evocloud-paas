Terraform Automation IaC
=========
[![Build Status](https://travis-ci.org/andrewrothstein/ansible-terraform.svg?branch=master)](https://travis-ci.org/andrewrothstein/ansible-terraform)

Installs [Terraform](https://www.terraform.io/)/)

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
    - app-terraform
```

License
-------

Powered by [Geant Technology, LLC](https://www.geanttechnology.com)

Author Information
------------------

Arnaud Some <arnaud.some@geanttechnology.net>