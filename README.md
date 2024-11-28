# Grillo's homelab playbooks

These playbooks are built to provision and maintain my homelab infrastructure :)

This assumes that the servers have proxmox installed and that they can be managed using ansible

# Playbooks

## Provision infrastructure

This playbook will try to provision/update 

```sh
ansible-playbook site.yml
```

## Rebuild specific app from scratch

If called directly, the playbooks will rebuild the containers and install the app from scratch. Information might be lost so use with caution.

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
      ansible_host: <ip_addr>
      ns_name: root

    <server_1>:
      ansible_host: <ip_addr>
      ns_name: aux

    <container_0>:
      vmid: <vmid>
      ansible_host: <ip_addr>
      ns_name: ns
      disk: 'local-lvm:4'
      cores: 1
      memory: 512
      unprivileged: False

    <container_1>:
      vmid: <vmid>
      ansible_host: <ip_addr>
      ns_name: maruchan
      disk: 'local-lvm:4'
      cores: 1
      memory: 1024
      unprivileged: True
      features:
        - nesting=1

    <container_2>:
      vmid: <vmid>
      ansible_host: <ip_addr>
      ns_name: ai
      disk: 'local-lvm:8'
      cores: 4
      memory: 4096
      unprivileged: True
      features:
        - nesting=1

# categorize between servers and containers
homelab:
  children:
    servers:
      hosts:
        <server_0>:
        <server_1>:
    containers:
      hosts:
        <container_0>:
        <container_1>:
        <container_2>:

# Which server and container are going to be used for each app
apps:
  children:
    app_ai:
      hosts:
        <server_1>:
        <container_2>:
    app_maruchan:
      hosts:
        <server_0>:
        <container_1>:
    app_dns:
      hosts:
        <server_0>:
        <container_0>:
```

## Server variables

### inventory/group_vars/homelab/main.yml
```yml
# make sure to encrypt your password using vault
proxmox_password: 12345
homelab_gateway_ip: <gateway>
homelab_domain: <domain>
```

### inventory/group_vars/homelab/servers.yml
```yml
# Required because proxmox permission system is not good enough
ansible_user: root
```

## App specific variables

### inventory/group_vars/app_dns.yml
```yml
dns_config:
  trusted:
  - <netmask of trusted range>
  forwarders:
  - <ip of resolver when not asking about this domain>
```


### inventory/group_vars/app_ai.yml
```yml
# This is the model that will be pulled using ramalama
ai_model: llama3.2:3b
```

### inventory/group_vars/app_maruchan.yml
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


