#! /usr/bin/python

import sys
from pathlib import Path


hostname: str = "proxmox"
field: str = "ansible_host"

inventory: Path = Path(sys.argv[1])
new_host_ip: str = sys.argv[2]

# Open the inventory in read mode
with inventory.open('r') as file:
    lines: list[str] = file.readlines()

# Replace the old host IP address with the new host IP address
i: int
found_on: int = -1
for i, line in enumerate(lines):
    if hostname in line:
        found_on = i
        break

if found_on > 0:
    for p, line in enumerate(lines[found_on:]):
        if field in line:
            old_text: str = line[line.find(field):].strip()
            new_text: str = f"{field}: {new_host_ip}"
            new_line: str = line.replace(old_text, new_text)
            break
    lines[found_on + p] = new_line

    # Open the inventory in write mode and overwrite the contents
    with inventory.open('w') as file:
        file.write(''.join(lines))
