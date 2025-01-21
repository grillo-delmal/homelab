# Traefik role

Let's you configure a traefik server, useful to expose web services and provide certs in a centralized way.

## Config example

### hosts_vars

```yml
traefik_dashboard_whitelist:
  - <a specific ip or ip range>
```

### host_vars on other servers

```yml
# Traefik Config
traefik_config:
  http:
    routers:
      to-<smth>:
        rule: Host(`<smth>.{{ domain_name }}`)
        service: <smth>
        middlewares:
        - <smth>-whitelist
    services:
      <smth>:
        loadBalancer:
          servers:
          - url: http://<private_ip>:8080
    middlewares:
      <smth>-whitelist:
        IPAllowList:
          sourceRange:
          - <local_network_mask>
```