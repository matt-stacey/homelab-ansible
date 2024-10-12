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
- To install the necessary packages and configuration on the Proxmox host (requires local SSH key to be linked to `root` on the Proxmox host)
    - `ssh_keygen -t rsa` to generate a key; take note of where it is saved
    - `ssh-copy-id i ~/.ssh/id_rsa.pub root@{host}` (subsitute the key location if needed)

### Is the Proxmox host connected properly?
After updating `inventory.yaml` with the appropriate `ansible_host` variable, run
`ansible -u root proxmox -m ping`

### Run the configuration playbook
- Configure the Proxmox host with `ansible-playbook playbooks/prepare_host.yaml -u root`
- It is not a bad idea to then remove the public key from `/root/.ssh/authorized_keys` on the Proxmox host

### Create a user on Proxmox
- Must be added both via the GUI and the CLI
    - `ANSIBLE_USER=ansible; adduser $ANSIBLE_USER && usermod -aG sudo $ANSIBLE_USER && passwd $ANSIBLE_USER`
    - Use the GUI (Datacenter > Permissions > Users) to add the user and match the password
    - Use the GUI (Datacenter > Permissions) to give Administrator role at `/`
- Connect your local SSH key to the Proxmox host
    - `ANSIBLE_USER=ansible; ssh-copy-id i ~/.ssh/id_rsa.pub $ANSIBLE_USER@{proxmox_host}` (subsitute the key location if needed)

### Run a playbook
- `ANSIBLE_USER=ansible; ansible-playbook playbooks/minimal.yaml -u $ANSIBLE_USER --exvtra-vars "vmid=101"` to add a container
- `ANSIBLE_USER=ansible; ansible-playbook playbooks/remove_container.yaml -u $ANSIBLE_USER --exvtra-vars "vmid=101"` to remove it

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

### add_user
`ansible-playbook playbooks/add_user.yaml -u root`
- Must be run as root, since that is the only user by default on the container
- Also copies your SSH key onto the container if it is located at `~/.ssh/id_rsa.pub`
