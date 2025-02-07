NerdCTL
=========
![Build Status](https://github.com/andrewrothstein/ansible-nerdctl/actions/workflows/build.yml/badge.svg)

Installs [nerdctl](https://github.com/containerd/nerdctl/)

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
    - app-nerdctl
```

License
-------

Powered by [Geant Technology, LLC](https://www.geanttech.com)

Author Information
------------------

Arnaud Some <arnaud.some@geanttech.com>