# DNS role

It hosts a bind9 server for local network usage.

It also connects to cloudflare to update dns through dyndns

Expects to run on a Fedora system

## Config example

### group_vars

```yml
cloudflare_token: <vault hidden... I expect>
gateway_ip: <ip>
domain_name: <server.domain.name>
base_domain_name: <domain.name>
```

### hosts_vars

```yml
# NS Role
dns_config:
  trusted:
  - <netmask of trusted range>
  forwarders:
  - <ip of resolver when not asking about this domain>
```

### host_vars on other servers

```yml

# DNS settings
dns_list:
  - "<some name... usually hostname>           IN      A       <local ip address>"
```