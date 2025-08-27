# Grillo's homelab playbooks

These playbooks are built to provision and maintain my homelab infrastructure :)

This assumes that the server has Fedora installed and that it can be managed using ansible.

# Playbooks

## Provision infrastructure

This playbook will try to provision/update all the infrastructure.

```sh
ansible-playbook -i <inventory path> -J site.yml
```

## Upgrade servers

This playbook will try to upgrade all infra packages 

```sh
ansible-playbook books/upgrade_all.yml
```

## Provision certs and containers to incus host

This playbook will provision / update the container infrastructure in the host incus servers using the information collected from the inventory.
This includes:
* Installing incus / incus webui / cockpit on the host machines.
* Getting the domain certs for the machines.
* Setting up the external storage.
* Creating all the child containers.
  * Setting up their visible and internal network.
  * Installing cockpit, sshd and firewalld.
  * Setting them up as a cockpit children from their host machine.
  * Creating ansible user.
  * Add ssh keys
  * Firewall rules, sshd is only accesible from host machine.

```sh
ansible-playbook books/incus_machines.yml
```

## Provision incus containers

This playbook for now will provision the incus containers with specific firewall rules

```sh
ansible-playbook books/incus_machines.yml
```

## Rebuild / update specific app

If called directly, the playbooks will install / update the referenced app in the targets marked by the inventory.

```sh
ansible-playbook books/role_{APPNAME}.yml
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
# Categorize between machine hosts and containers
machines:
  hosts:
    <server_0>:
    <server_1>:
containers:
  hosts:
    <container_0_0>:
    <container_0_1>:
    <container_0_2>:
    <container_1_0>:
    <container_1_1>:
    <container_1_2>:

# Assign roles to each container
# (assuming they are correctly configured for them)
roles:
  children:
    role_dns:
      hosts:
        <container_0_0>:
    role_storage:
      hosts:
        <container_0_1>:
    role_ai:
      hosts:
        <container_0_2>:
        <container_1_2>:
    role_maruchan:
      hosts:
        <container_1_0>:
    role_traefik:
      hosts:
        <container_1_1>:
```

## Server variables

### inventory/group_vars/all/main.yml

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

### inventory/group_vars/all/machines.yml

```yml
# Make sure to create an ansible user on your incus host machines
ansible_user: ansible
```

### inventory/group_vars/all/containers.yml

```yml
# Make sure to have this file as this
ansible_user: ansible
ansible_host: "{{ (internal_host | split('/'))[0] }}"
parent_ip: |-
  {{
    (groups['machines'] |
      map('extract', hostvars) |
      selectattr('hostname', 'equalto', parent_machine))[0].ansible_host
  }}
ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o CheckHostIP=no -o ProxyCommand="ssh -W %h:%p -q root@{{ parent_ip }}"'
```

## Host variables

### inventory/host_vars/<server_0>.yml

```yml
# make sure to encrypt your sensible data using vault
ansible_host: <ip_addr>
ns_name: root

letsencrypt_domain_name: "{{ hostname }}.{{ domain_name }}"

btrfs_storage:
  device: /dev/disk/by-uuid/xxxxx
  path: /bindmounts
```

### inventory/host_vars/<container_0>.yml

```yml
hostname: ns

visible_host: <IP/MASK of visible ip in bridged device>
internal_host: <IP/MASK of internal ip (incus network)>

parent_machine: nano

# Container
incus_config:
  disk: '4GiB'
  cores: 2
  memory: 512MiB
  privileged: False
  nesting: False

# External storage
storage_mnt:
  - path: <path inside btrfs_storage>
    target: <path in target>
    size: <capped by btrfs subvolume system (optional)>

# NS Role (role specific config)
dns_config:
  trusted:
  - <netmask of trusted range>
  forwarders:
  - <ip of resolver when not asking about this domain>
```

