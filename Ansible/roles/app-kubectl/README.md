Kubectl
=========

Installs [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

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
    - rancher-kubectl
```

Note
----
Kubectl can be deployed on the Rancher load-balancer with the kubeconfig file setup from the k3s.yml file.


License
-------

Powered by [Geant Technology, LLC](https://www.geanttech.com)

Author Information
------------------

Arnaud Some <arnaud.some@geanttech.com>