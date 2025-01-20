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

# About roles

It is expected for roles to be configured on each server's host_vars file.

Make sure you add the contarner/server to it's propper role group in the inventory

Each role configuration should be documented in it's folder's README.md.

A server/container can have multiple roles.

# Requirements

It's important for the inventory to provide all the required information so that the Containers and VMs get built.

Here is an example template based on my planned local infra as of now, might be outdated though...

Last update 2025/01/20

## Inventory

### inventory/main.yml

```yml
# Servers and container list
all:
  hosts:
    <server_0>:
    <container_0>:
    <container_1>:
    <container_2>:
    <container_3>:
    <container_4>:

# Group server and containers here
# As for now it assumes that all the containers are in homelab
# which has 1 server and multiple containers
hardware:
  children:
    homelab:
      hosts:
        <server_0>:
        <container_0>:
        <container_1>:
        <container_2>:
        <container_3>:
        <container_4>:
    rpi:
      hosts:
        <server_1>:
    router:
      hosts:
        <server_2>:
## At some point in the future
#    another_homelab:
#      hosts:
#        <server_3>:
#        <container_5>:
#        <container_6>:


# Categorize between proxmox hosts and containers
# Only the one in homelab will be recognized as the parent of the containers
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
        <container_3>:
        <container_4>:

# Assign roles to each container
# (assuming they are correctly configured for them)
roles:
  children:
    role_dns:
      hosts:
        <container_0>:
    role_storage:
      hosts:
        <container_1>:
    role_ai:
      hosts:
        <container_2>:
    role_maruchan:
      hosts:
        <container_3>:
    role_traefik:
      hosts:
        <container_4>:
```

## Server variables

### inventory/group_vars/homelab/main.yml

```yml
# make sure to encrypt your sensible data using vault
gateway_ip: <gateway>

domain_name: <domain>
base_domain_name: <base_domain>
cloudflare_token: <token>

letsencrypt_email: <mail>
letsencrypt_challenge_type: dns_01
```

### inventory/group_vars/homelab/servers.yml

```yml
# Required because proxmox permission system is not good enough
ansible_user: root
```

## Host variables

### inventory/host_vars/<server_0>.yml

```yml
# make sure to encrypt your sensible data using vault
ansible_host: <ip_addr>
ns_name: root

proxmox_server:
  password: 12345

btrfs_storage:
  path: /bindmounts
  device: /dev/sdb0
```

### inventory/host_vars/<container_0>.yml

```yml
ansible_host: <ip_addr>
hostname: ns

# Container
proxmox_container:
  vmid: <vmid>
  disk: 'local-lvm:4'
  cores: 1
  memory: 512
  unprivileged: False

# NS Role
dns_config:
  trusted:
  - <netmask of trusted range>
  forwarders:
  - <ip of resolver when not asking about this domain>
```

