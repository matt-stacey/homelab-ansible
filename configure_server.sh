#! /usr/bin/bash

# Parse arguments
remove_hosts=
while (( $# )); do
    case $1 in
        --remove-hosts)
            remove_hosts=1
            ;;
        --*)
            echo 'bad option: '$1
            ;;
        *)
            echo $1' not parsed'
            ;;
    esac
    shift
done


# Remove known_hosts if requested to prevent key collisions
if [ $remove_hosts ]; then
    rm ~/.ssh/known_hosts
fi


# Ansible Work
ansible-playbook playbooks/create_containers.yaml
ansible-playbook playbooks/prepare_containers.yaml
