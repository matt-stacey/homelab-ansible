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

## Your configuration
Now prepare the following:
    - `inventory.yaml` - under 'containers' add all of the desired containers and their IP addresses
    - `host_vars` folder - create a yaml for each container added to inventory.yaml and include the VMID and corresponding IP address
    - `roles` folder
        - create a folder for each container added to inventory.yaml
        - create a `tasks` subfolder containing main.yaml with role-specific tasks
        - create a `defaults` subfolder containing any variables needed
    - The `vault` folder (ignored by the repository)
        - `api_password` - password for the api_user
        - `root_ct_pass` - default password for the root user for containers
        - `default_ct_pass` - default password for the api_user for containers

## Configure Proxmox Host
- To install the necessary packages and configuration on the Proxmox host (requires local SSH key to be linked to `root` on the Proxmox host)
    - `ssh-keygen -t rsa` to generate a key; take note of where it is saved
    - `ssh-copy-id i ~/.ssh/id_rsa.pub root@{host}` (subsitute the key location if needed)

### Is the Proxmox host connected properly?
After updating `inventory.yaml` with the appropriate `ansible_host` variable, run
`ansible -u root proxmox -m ping`

### Run the configuration playbook
- Update the `api_user` field in `group_vars/all.yaml` for the non-root user on Proxmox
- Configure the Proxmox host with `ansible-playbook playbooks/prepare_proxmox_host.yaml`
    - Configures repositories
    - Updates installed packages
    - Installs required packages
    - Adds a non-root user to the Proxmox host

### Create a non-root user on Proxmox GUI
- The non-root Linux user was created when `prepare_proxmox_host.yaml` was ran
- The non-root user must still be added via the GUI
    - Use the GUI (Datacenter > Permissions > Users) to add the user (with the same username from `group_vars/all.yaml`) and match the password in `vault/api_password`
    - Use the GUI (Datacenter > Permissions) to give Administrator role at `/`

### Run a playbook
- `ansible-playbook playbooks/minimal.yaml --extra-vars "vmid=101"` to add a container
- `ansible-playbook playbooks/remove_container.yaml --extra-vars "vmid=101"` to remove it

## Playbooks

### create_container
`ansible-playbook playbooks/create_container.yaml`
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

### add_user
`ansible-playbook playbooks/add_user.yaml`
- Runs as root, since that is the only user by default on the container
- Also copies your local SSH key onto the container if it is located at `~/.ssh/id_rsa.pub`
