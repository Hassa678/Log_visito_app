import os
import json
import subprocess

# Set output file path
output_path = os.path.join("ansible", "inventory.ini")

# Run 'terraform output -json' and parse it
terraform_output = subprocess.check_output(["terraform", "output", "-json"])
data = json.loads(terraform_output)

# Extract IPs
private_ips = data["app_private_ips"]["value"]
bastion_ip = data["bastion_public_ip"]["value"]

# SSH key path
ssh_key = "~/.ssh/another_key.pem"

# Create inventory content
inventory = "[webservers]\n"
for i, ip in enumerate(private_ips, 1):
    inventory += (
        f"app{i} ansible_host={ip} ansible_user=ec2-user "
        f"ansible_ssh_private_key_file={ssh_key} "
        f"ansible_ssh_common_args='-o ProxyCommand=\"ssh -i {ssh_key} ec2-user@{bastion_ip} -W %h:%p\"'\n"
    )

inventory += "\n[bastion]\n"
inventory += (
    f"bastion ansible_host={bastion_ip} ansible_user=ec2-user "
    f"ansible_ssh_private_key_file={ssh_key}\n"
)

# Write to file
os.makedirs("ansible", exist_ok=True)
with open(output_path, "w") as f:
    f.write(inventory)

print(f"Inventory file generated at: {output_path}")
