ClamAV
=========
[![CI](https://github.com/geerlingguy/ansible-role-clamav/workflows/CI/badge.svg?event=push)](https://github.com/geerlingguy/ansible-role-clamav/actions?query=workflow%3ACI)

Installs [ClamAV](https://www.clamav.net/)

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
    - app-clamav
```

License
-------

Powered by [Geant Technology, LLC](https://www.geanttech.com)

Author Information
------------------

Arnaud Some <arnaud.some@geanttech.com>