FreeIPA-Identity-Server
=========
[![Build Status](https://travis-ci.org/samdoran/ansible-role-caddy.svg?branch=master)](https://travis-ci.org/samdoran/ansible-role-caddy)

Installs [FreeIPA Identity Server](https://www.freeipa.org/)

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
    - server-freeipa
```

License
-------

Powered by [Geant Technology, LLC](https://www.geanttech.com)

Author Information
------------------

Arnaud Some <arnaud.some@geanttech.net>