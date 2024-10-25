#! /usr/bin/bash

# Parse arguments
api_user=
while (( $# )); do
    case $1 in
        --api-user)
            api_user=$1
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


# Replace existing_user with new_user in the file
if [ $api_user ]; then
    file="group_vars/all.yaml"
    sed -i "s/api_user: .* #/api_user: $api_user #/" "$file"
fi


# Ansible Preparation - Proxmox Host
ansible -u root proxmox -m ping
ansible-playbook playbooks/prepare_proxmox_host.yaml

