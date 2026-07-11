KUBESEC CLI
=========

Installs [Kubesec](https://github.com/controlplaneio/kubesec)

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
    - app-kubesec
```

Usage Examples
-------------------

### Scanning

Scan Kubernetes resources from local files or standard input.

Kubesec can scan multiple YAML documents in a single input file, or scan documents from multiple files at once, as long
as they are correctly formatted as multiple documents separated by `---`.

```bash
# Scan a specific local YAML file
kubesec scan ./deployment.yaml

# Scan from standard input (JSON or YAML)
cat file.json | kubesec scan -

# Scan a rendered Helm chart
helm template -f values.yaml ./chart | kubesec scan /dev/stdin

# Scan multiple YAML documents separated by '---'
{ cat test/asset/multi.yml; echo "---"; cat test/asset/critical.yml; } | kubesec scan -
```


Authors
------------------

Created by the [EvoCloud Engineering Team](https://evocloud.dev). Copyright (C) 2025 EvoCloud, Inc.