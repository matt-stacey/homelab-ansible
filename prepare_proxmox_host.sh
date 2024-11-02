#! /usr/bin/bash

# Parse arguments
api_user=
while (( $# )); do
    case $1 in
        --api-user)
            shift
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
    sed -i "s/api_user:.*#/api_user: $api_user  #/" "$file"
fi


# Ansible Preparation - Proxmox Host
ansible -u root proxmox -m ping

# Throws an error that it fails to find api_password (in proxmox.yaml),
# but it seems to be working properly
ansible-playbook playbooks/prepare_proxmox_host.yaml
