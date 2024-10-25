#! /usr/bin/bash

# Remove known_hosts to prevent key collisions
rm ~/.ssh/known_hosts

# Ansible Work
ansible-playbook playbooks/create_containers.yaml
ansible-playbook playbooks/prepare_containers.yaml

