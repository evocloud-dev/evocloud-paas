#!/bin/bash

########################
# include the magic
########################
. demo-magic.sh

# hide the evidence
clear

p "#Use Trivy to output the number of vulnerabilities in the nginx:1.21.6 container image..."
pei "trivy image --vuln-type os --ignore-unfixed nginx:1.21.6 | grep Total"

p "#Use Trivy to scan the nginx:1.21.6 container image and save the output to nginx.1.21.6.json..."
pei "trivy image --vuln-type os --ignore-unfixed nginx:1.21.6 -f json -o nginx.1.21.6.json"

p "#Use copa to patch the nginx:1.21.6 container image and save the patched container image to nginx:1.21.6-patched..."
pei "copa patch -i docker.io/library/nginx:1.21.6 -r nginx.1.21.6.json -t 1.21.6-patched"

p "#Check that the nginx:1.21.6-patched container image is present locally..."
pei "docker images | grep 1.21.6"

p "#Use Trivy to scan the nginx:1.21.6-patched container image..."
pei "trivy image --vuln-type os --ignore-unfixed nginx:1.21.6-patched | grep Total"

p "#Verify that the patched container image runs..."
pei "docker run nginx:1.21.6-patched"

p "Learn more about EvoCloud at - https://www.evocloud.dev"
