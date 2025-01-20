# Forgejo role

It hosts a forgejo server. 

It starts with some basic configuration, a sqlite database and an admin user precreated.

Base configuration is really basic, so use it at your own risk.

Expects to run on a Fedora system

## Config example

### hosts_vars

```yml
# Forgejo Config
forgejo_config:
  app:
    app_name: 'sets APP_NAME in app.ini'
    app_slogan: 'sets APP_SLOGAN in app.ini'
    server:
      domain: 'replaces [server]DOMAIN in app.ini'
      ssh_domain: 'replaces [server]SSH_DOMAIN in app.ini'
      root_url: 'replaces [server]ROOT_URL in app.ini'
      protocol: 'replaces [server]PROTOCOL in app.ini'
      http_addr: 'replaces [server]HTTP_ADDR in app.ini'
      http_port: 'replaces [server]HTTP_PORT in app.ini'

  admin:
    username: bob
    password: '12345'
    email: bob@mail.server
```
