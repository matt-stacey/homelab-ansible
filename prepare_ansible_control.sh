#! /usr/bin/bash

# Parse arguments
overwrite_venv=
host=
while (( $# )); do
    case $1 in
        --overwrite-venv)
            overwrite_venv=1
            ;;
        --host)
            shift
            host=$1
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

if [ ! $host ]; then
    echo No host given!
    echo Specify IP address of Proxmox host with '--host'
    return
fi


# Install Required Packages
sudo apt update
sudo apt install python3 # python3-venv


# Set Up Variables
project_root=`git rev-parse --show-toplevel`
proj_name=ansible
venv_path=${project_root}/${proj_name}_venv


# Create Virtual Environment
if [ $overwrite_venv ]; then
    rm -rf $venv_path
fi

if [ ! -d ${venv_path} ]; then
    python3 -m venv ${venv_path}
    source ${venv_path}/bin/activate
    python -m pip install --upgrade pip
    python -m pip install -r requirements.txt
else
    source ${venv_path}/bin/activate
fi


# SSH Preparation
key_file=~/.ssh/id_rsa.pub

if [ ! -f "$key_file" ]; then
    ssh-keygen -t rsa
else
    echo "SSH public key exists at $key_file; continuing"
fi

ssh-copy-id -i $key_file "root@$host"


# Update inventory.yaml with Proxmox host
inventory=${project_root}/inventory.yaml
python update_proxmox_host.py $inventory $host
