# homelab-ansible
Ansible code for a Proxmox-based Home Lab

## Expected packages
- python3
- python3-venv

## Virtual Environment Configuration
- Create the virtual environment
    - `python3 -m venv ansible_venv`
    - `source ansible_venv/bin/activate`
    - `python -m pip install --upgrade pip`
    - `python -m pip install -r requirements.txt`

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
