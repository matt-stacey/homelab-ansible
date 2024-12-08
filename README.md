# homelab-ansible
Ansible code for a Proxmox-based Home Lab

## Configure Ansible Control Node
### Scenic Route
#### Expected packages
- python3
- python3-venv

#### Local Virtual Environment Configuration
- Create the local virtual environment
    - `python3 -m venv ansible_venv`
    - `source ansible_venv/bin/activate`
    - `python -m pip install --upgrade pip`
    - `python -m pip install -r requirements.txt`

#### Configure Proxmox Host SSH Trust
- To install the necessary packages and configuration on the Proxmox host (requires local SSH key to be linked to `root` on the Proxmox host)
    - `ssh-keygen -t rsa` to generate a key; take note of where it is saved
    - `ssh-copy-id -i ~/.ssh/id_rsa.pub root@{Proxmox IP}` (subsitute the key location if needed)

#### Inventory update
Add the Proxmox host to `inventory.yaml` under the `proxmox` group
- `pve` is the node name
- `ansible_host:` is the ip address

#### Future Changes
If the Proxmox host changes in the future:
- Update the IP address at `pve > Network > vmbr0` in the Proxmox GUI
- Update `/etc/network/interfaces` (should be done by the GUI update)
- Update `/etc/hosts`

### Express Route
`source prepare_ansible_control.sh --host <Proxmox IP> [--overwrite-venv]`

## Configure Proxmox Host
### Scenic Route
Update the `api_user` field in `group_vars/all.yaml` for the non-root user on Proxmox

#### Is the Proxmox host connected properly?
After updating `inventory.yaml` with the appropriate `ansible_host` variable, run
`ansible -u root proxmox -m ping`

#### Run the configuration playbook
- Configure the Proxmox host with `ansible-playbook playbooks/prepare_proxmox_host.yaml`
    - Configures repositories
    - Updates installed packages
    - Installs required packages
    - Adds a non-root user to the Proxmox host

### Express Route
`bash prepare_proxmox_host.sh [-- api-user <username>]`

### Create a non-root user on Proxmox GUI
- The non-root Linux user was created when `prepare_proxmox_host.yaml` was ran
- The non-root user must still be added via the GUI
    - Use the GUI (Datacenter > Permissions > Users) to add the user (with the same username from `group_vars/all.yaml`) and match the password in `vault/api_password`
    - Use the GUI (Datacenter > Permissions) to give Administrator role at `/`

## Configuration for Home Lab Server
Now prepare the following:
- `inventory.yaml` - under 'containers' add all of the desired containers and their IP addresses
- `host_vars` folder - create a yaml for each container added to inventory.yaml and include the VMID and corresponding IP address
- `roles` folder
    - create a folder for each container added to inventory.yaml
    - create a `tasks` subfolder containing main.yaml with role-specific tasks
    - if needed, create a `defaults` subfolder containing any variables needed
- The `vault` folder (ignored by the repository)
    - `api_password` - password for the api_user
    - `root_ct_pass` - default password for the root user for containers
    - `default_ct_pass` - default password for the api_user for containers

### Run a playbook
Test that your configuration works properly:
- `ansible-playbook playbooks/minimal.yaml --extra-vars "vmid=101"` to add a container
- `ansible-playbook playbooks/remove_container.yaml --extra-vars "vmid=101"` to remove it

### Configure the Server
#### Scenic Route
It may be a good idea to remove `~/.ssh/known_hosts` to prevent SSH key collisions and MITM warnings. The alternative is to set `host_key_checking` to false in `ansible.cfg`, but that is not recommended.

Next, create and configure the containers by running:
- `ansible-playbook playbooks/create_containers.yaml`
- `ansible-playbook playbooks/prepare_containers.yaml`

#### Express Route
`bash configure_server.sh [--remove-hosts]`

### crontab
Use crontab on the Ansible control node
- Add `playbooks/configure_containers.yaml` to ensure regular config checks
- Add `playbooks/update_containers.yaml` to keep packages up to date
- Add `playbooks/restart_container.yaml` with VMIDs to regularly restart the containers

## Playbooks

### prepare_proxmox_host
`ansible-playbook playbooks/prepare_proxmox_host.yaml`
- Switches to community repos
- Ensures `api_user` set in `group_vars/all.yaml` exists on the PVE machine
- Installs required packages

### create_containers
`ansible-playbook playbooks/create_containers.yaml`
- Creates containers as listed in the `containers` group in `inventory.yaml`
- Recommend creation of a configuration file in `host_vars/<hostname>.yaml`
    - Include an assigned `vmid` or Proxmox will grab the "next" one
    - Include `netif` (mostly for IP address, or it will use DHCP)
    - Additional configuration can be done against what is found in `create_containers.yaml`
    - Default values are found in `group_vars/proxmox.yaml` under `defaults`

### remove_container
`VMID=000; ansible-playbook playbooks/remove_container.yaml --extra-vars "vmid=$VMID"`
- Stops and removes container with `$VMID`
- Good for loops on the CLI

### minimal
`VMID=000; ansible-playbook playbooks/minimal.yaml --extra-vars "vmid=$VMID"`
- Other variables can be specified; see `minimal.yaml` for CLI args

### prepare_containers
`ansible-playbook playbooks/prepare_containers.yaml`
- Runs "gather_facts" against all containers: there is a Proxmox/Ansible issue where the containers return "unreachable" the first time they are sent instructions, so this gets that out of the way
- Adds `api_user` to the containers
- Calls `configure_containers.yaml`

### configure_containers
`ansible-playbook playbooks/configure_containers.yaml`
- Assigns the role `ct_base` to all containers
- Assigns container-specific roles by-name as defined in `roles/<name>/tasks/main.yaml`, if present

### configure_containers
`ansible-playbook playbooks/update_containers.yaml`
- Uses apt to update all containers
