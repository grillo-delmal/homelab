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
    <container_0>:
    <container_1>:
    <container_2>:
    <container_3>:
    <container_4>:

# homelab is the one with the main proxmox instalation
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
        <container_3>:
        <container_4>:

# Which server and container are going to be used for each app
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

## Host variables

### inventory/host_vars/<server_0>.yml

```yml
ansible_host: <ip_addr>
ns_name: root

storage_btrfs_path: /bindmounts
storage_btrfs_device: /dev/sdb0
```

### inventory/host_vars/<container_0>.yml

```yml
ansible_host: <ip_addr>

# Container
vmid: <vmid>
ns_name: ns
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


### inventory/host_vars/<container_2>.yml

```yml
ansible_host: <ip_addr>

# Container
vmid: <vmid>
ns_name: maruchan
disk: 'local-lvm:4'
cores: 1
memory: 1024
unprivileged: True
features:
  - nesting=1

# External storage
storage_mnt:
  - path: /maruchan
    target: /storage
    size: 50M

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

### inventory/host_vars/<container_3>.yml

```yml
ansible_host: <ip_addr>

# Container
vmid: <vmid>
ns_name: ai
disk: 'local-lvm:8'
netif:
  - "ip=<private_ip>,bridge=<traefik_private_network>"
cores: 4
memory: 4096
unprivileged: True
features:
  - nesting=1

# AI Role
ai_model: llama3.2:3b

# Traefik Config
traefik_config:
  http:
    routers:
      to-ai:
        rule: Host(`ai.{{ domain_name }}`)
        service: ai
        middlewares:
        - whitelist
    services:
      ai:
        loadBalancer:
          servers:
          - url: http://<private_ip>:8080
    middlewares:
      whitelist:
        IPAllowList:
          sourceRange:
          - <local_network_mask>
```


### inventory/host_vars/<container_4>.yml

```yml
ansible_host: <ip_addr>

# Container
vmid: <vmid>
ns_name: traefik
disk: 'local-lvm:8'
cores: 2
memory: 1024
unprivileged: True
features:
  - nesting=1
netif:
  - "ip=<private_ip>,bridge=<traefik_private_network>"

# DNS settings
dns_list:
  - "*           IN      A       <ip_addr>"

traefik_dashboard_whitelist:
  - <Filtered IPs>
```

## Server variables

### inventory/group_vars/homelab/main.yml

```yml
# make sure to encrypt your password using vault
proxmox_password: 12345
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

