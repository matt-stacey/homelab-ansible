# homelab-ansible
Ansible code for a Proxmox-based Home Lab

## Expected packages
- python3
- python3-venv

## Local Virtual Environment Configuration
- Create the local virtual environment
    - `python3 -m venv ansible_venv`
    - `source ansible_venv/bin/activate`
    - `python -m pip install --upgrade pip`
    - `python -m pip install -r requirements.txt`

## Configure Proxmox Host
To install the necessary packages and configuration on the Proxmox host (requires local SSH key to be linked to `root` on the Proxmox host):
`ansible-playbook playbooks/prepare_host.yaml -u root`

## Ansible Usage

### Create a user on Proxmox
- Must be added both via the GUI and the CLI
    - `ANSIBLE_USER=ansible; adduser $ANSIBLE_USER && usermod -aG sudo $ANSIBLE_USER && passwd $ANSIBLE_USER`
    - Use the GUI (Datacenter > Permissions > Users) to match the password
    - Use the GUI (Datacenter > Permissions) to give Administrator role at `/`

### Connect your SSH key to the hosts
- This can be provided at container creation
- If it wasn't
    - `ssh_keygen -t rsa` to generate a key; take note of where it is saved
    - Use PVE to edit `/etc/ssh/sshd_config`, adding in the Authentication section `PermitRootLogin yes`
    - `ANSIBLE_USER=ansible; ssh-copy-id i ~/.ssh/id_rsa.pub $ANSIBLE_USER@{host}` (subsitute the key location if needed)
    - Remove the edit made above

### Are all of the hosts connected properly?
After updating `inventory.yaml` with the appropriate hosts, run
- `ANSIBLE_USER=ansible; ansible -u $ANSIBLE_USER proxmox -m ping`

### Run a playbook
`ANSIBLE_USER=ansible; ansible-playbook playbooks/create_container.yaml -u $ANSIBLE_USER`

## Playbooks

### create_container
`ANSIBLE_USER=ansible; ansible-playbook playbooks/create_container.yaml -u $ANSIBLE_USER`
- Creates containers as listed in the `containers` group in `inventory.yaml`
- Recommend creation of a configuration file in `host_vars/<hostname>.yaml`
    - Include an assigned `vmid` or Proxmox will grab the "next" one
    - Include `netif` (mostly for IP address, or it will use DHCP)
    - Additional configuration can be done against what is found in `create_containers.yaml`
    - Default values are found in `group_vars/proxmox.yaml` under `defaults`

### remove_container
`ANSIBLE_USER=ansible; VMID=000; ansible-playbook playbooks/remove_container.yaml -u $ANSIBLE_USER --extra-vars "vmid=$VMID"`
- Stops and removes container with $VMID
- Good for loops on the CLI

### minimal
`ANSIBLE_USER=ansible; VMID=000; ansible-playbook playbooks/minimal.yaml -u $ANSIBLE_USER --extra-vars "vmid=$VMID"`
- Other variables can be specified; see `minimal.yaml` for CLI args
