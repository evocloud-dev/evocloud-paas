Hashicorp Vault Client Binary
=====

[![Build Status](https://travis-ci.org/andrewrothstein/ansible-vault.svg?branch=master)](https://travis-ci.org/andrewrothstein/ansible-vault)


Installs [Hashicorp Vault Client Binary](https://www.vaultproject.io/)

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
    - app-vault
```

License
-------

Powered by [Geant Technology, LLC](https://www.geanttech.com)

Author Information
------------------

Arnaud Some <arnaud.some@geanttech.com>