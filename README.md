# Grillo's homelab playbooks

These playbooks are built to provision and maintain my homelab infrastructure :)

This assumes that the servers have proxmox installed and that they can be managed using ansible.

I'm also have an updated version of `community-general` collection for the updated proxmox tasks.

# Playbooks

## Provision infrastructure

This playbook will try to provision/update all the infrastructure.

```sh
ansible-playbook site.yml
```

## Upgrade servers

This playbook will try to upgrade all infra packages 

```sh
ansible-playbook books/upgrade_all.yml
```

## Provision certs and containers to proxmox host

This playbook will provision / update the container infrastructure using the information collected from the inventory.

```sh
ansible-playbook books/setup_servers.yml
```

## Rebuild / update specific app

If called directly, the playbooks will install / updates the referenced app in the targets marked by the inventory.

```sh
ansible-playbook books/build_{APPNAME}.yml
```

# Requirements

It's important for the inventory to provide all the required information so that the Containers and VMs get built.

Here is an example template based on my planned local infra as of now, might be outdated though...

## Inventory

### inventory/main.yml
```yml
# Set ips and provisioning information for containers
all:
  hosts:
    <server_0>:
    <server_1>:
    <container_0>:
    <container_1>:
    <container_2>:

# homelab is the one with the main proxmox instalation
hardware:
  children:
    homelab:
      hosts:
        <server_0>:
        <container_0>:
        <container_1>:
        <container_2>:
    other:
      hosts:
        <server_1>:

# Categorize between servers and containers
type:
  children:
    proxmox:
      hosts:
        <server_0>:
    containers:
      hosts:
        <container_0>:
        <container_1>:
        <container_2>:
    servers:
      hosts:
        <server_1>:

# Which server and container are going to be used for each app
roles:
  children:
    role_ai:
      hosts:
        <server_1>:
    role_maruchan:
      hosts:
        <container_1>:
    role_dns:
      hosts:
        <container_0>:
```

## Host variables

### inventory/host_vars/<server_0>.yml

```yml
ansible_host: <ip_addr>
ns_name: root
```

### inventory/host_vars/<server_1>.yml

```yml
ansible_host: <ip_addr>
ns_name: aux
```

### inventory/host_vars/<container_0>.yml

```yml
vmid: <vmid>
ansible_host: <ip_addr>
ns_name: ns
disk: 'local-lvm:4'
cores: 1
memory: 512
unprivileged: False
```

### inventory/host_vars/<container_1>.yml

```yml
vmid: <vmid>
ansible_host: <ip_addr>
ns_name: maruchan
disk: 'local-lvm:4'
cores: 1
memory: 1024
unprivileged: True
features:
  - nesting=1
```

### inventory/host_vars/<container_2>.yml

```yml
vmid: <vmid>
ansible_host: <ip_addr>
ns_name: ai
disk: 'local-lvm:8'
cores: 4
memory: 4096
unprivileged: True
features:
  - nesting=1
```

## Server variables

### inventory/group_vars/homelab/main.yml
```yml
# make sure to encrypt your password using vault
proxmox_password: 12345
homelab_gateway_ip: <gateway>
homelab_domain: <domain>

letsencrypt_cloudflare_token: <token>
letsencrypt_email: <mail>
letsencrypt_challenge_type: dns_01
letsencrypt_base_domain_name: <base_domain>
letsencrypt_domain_name: "{{ ns_name }}.{{ homelab_domain }}"
```

### inventory/group_vars/homelab/servers.yml
```yml
# Required because proxmox permission system is not good enough
ansible_user: root
```

## App specific variables

### inventory/group_vars/roles/role_dns.yml
```yml
dns_config:
  trusted:
  - <netmask of trusted range>
  forwarders:
  - <ip of resolver when not asking about this domain>
```

### inventory/group_vars/roles/role_ai.yml
```yml
# This is the model that will be pulled using ramalama
ai_model: llama3.2:3b
```

### inventory/group_vars/roles/role_maruchan.yml
```yml
# This variable gets written as a json file to be used as the bot config
# Other service hostnames will get overwritten during provisioning
# To see more parameters, check the bot's repo.
maruchan_config:
  bot: 
    token: <discord token>
    admin: <privileged user id>
  starbound:
    rcon_password: <rcon_password>
```


