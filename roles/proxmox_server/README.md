# Proxmox Server role

The main role configures a server, the others are used to provision and configure containers


## Config example

### Server host_vars

```yml
letsencrypt_domain_name: "<if you want to configure a cert on proxmox>"

proxmox_server:
  password: "12345"

btrfs_storage:
  device: <a device>
  path: <where to mount it>
```

### Container specific host_vars

```yml
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
```