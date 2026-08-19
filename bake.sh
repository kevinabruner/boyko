#!/bin/bash
app_name="boyko"

echo "--- Pulling latest configuration ---"
git pull || { echo "Git pull failed"; return 1; }

echo "--- Searching NetBox for $app_name ---"

# 1. Fetch the data using a single jq call
RESULT=$(ansible-inventory --list | jq -r --arg repo "$app_name" '
  ._meta.hostvars | to_entries[] | 
  select(
    .value.custom_fields.repos == $repo and 
    (.value.device_roles | contains(["vm-template"]))
  ) | 
  "\(.key) \(.value.custom_fields.vmid)"
')

# 2. Parse the result
INVENTORY_HOSTNAME=$(echo $RESULT | awk '{print $1}')
VMID=$(echo $RESULT | awk '{print $2}')

if [ "$VMID" == "null" ] || [ -z "$VMID" ]; then
    echo "Error: Could not find VMID for $app_name in inventory."
    exit 1
fi


echo "--- Found VMID: $VMID  ---"

echo "--- Running Pre-flight Checklist ---"
ansible-playbook _packer-preflight.yaml -e "vmid=$VMID" -e "target_app=$app_name" -e "pve_node=pve" -K

echo "--- Baking Gold Image for: $app_name ---"
time packer build \
    -var "target_app=$app_name" \
    -var "proxmox_vmid=$VMID" \
    -var-file="packer/variables.pkrvars.hcl" \
    -var-file="packer/secret.pkrvars.hcl" \
    packer/golden-image.pkr.hcl