#! /usr/bin/bash

host=$1

# Required Packages
apt update
apt install python3 python3-venv

# Virtual Environment
python3 -m venv ansible_venv
source ansible_venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

# SSH Preparation
ssh-keygen -t rsa
ssh-copy-id i ~/.ssh/id_rsa.pub root@$host

