# Grillo's homelab playbooks

These playbooks are built to provision and maintain my homelab infrastructure :)

This assumes that the server has Fedora installed and that it can be managed using ansible.

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

This playbook will provision / update the container infrastructure in the main server using the information collected from the inventory.

```sh
ansible-playbook books/setup_homelab.yml
```

## Rebuild / update specific app

If called directly, the playbooks will install / update the referenced app in the targets marked by the inventory.

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
# Group server and containers here
# As for now it assumes that all the containers are in homelab
# which has 1 server and multiple containers
homelab:
  hosts:
    <server_0>:
    <container_0>:
    <container_1>:
    <container_2>:
    <container_3>:
    <container_4>:

# Categorize between machine hosts and containers
# The containers will get created on all the hosts that intersect
# between machines and homelab, so make sure that its only one
type:
  children:
    machines:
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

# Add the ssh pubkeys that will be used to access the server here!
ssh_pub_keys:
- <pubkey 1>
- <pubkey 2>

letsencrypt_email: <mail>
letsencrypt_challenge_type: dns_01
```

### inventory/group_vars/homelab/machines.yml

```yml
# Required for now
ansible_user: root
```

## Host variables

### inventory/host_vars/<server_0>.yml

```yml
# make sure to encrypt your sensible data using vault
ansible_host: <ip_addr>
ns_name: root

letsencrypt_domain_name: "{{ hostname }}.{{ domain_name }}"

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

# Container
incus_config:
  disk: '8GiB'
  cores: 2
  memory: 2GiB
  privileged: False
  nesting: True

# External storage
storage_mnt:
  - path: <path inside btrfs_storage>
    target: <path in target>
    size: <capped by btrfs subvolume system (optional)>

# NS Role
dns_config:
  trusted:
  - <netmask of trusted range>
  forwarders:
  - <ip of resolver when not asking about this domain>
```

