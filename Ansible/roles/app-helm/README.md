Helm CLI
=========
[![Build Status](https://travis-ci.org/andrewrothstein/ansible-terraform.svg?branch=master)](https://travis-ci.org/andrewrothstein/ansible-terraform)

Installs [Helm](https://helm.sh/docs/intro/install/)/)

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
    - app-helm
```

License
-------

Powered by [Geant Technology, LLC](https://www.geanttech.com)

Author Information
------------------

Arnaud Some <arnaud.some@geanttech.com>