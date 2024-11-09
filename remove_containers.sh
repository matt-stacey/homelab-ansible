#!/bin/bash

while [ $# -gt 0 ]; do
    echo 'ansible-playbook playbooks/remove_container.yaml -u ansible_pm --extra-vars "vmid='$1'"'
    ansible-playbook playbooks/remove_container.yaml -u ansible_pm --extra-vars "vmid=$1"
    echo 'sleep 3'
    sleep 3
    shift
done
