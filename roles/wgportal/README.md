# WGPortal role

Host a WGPortal server. Provides an easy way to setup WireGuard connections from a webpage.
My default playbooks don't make use of all their security features, so make sure to add extra security on top (firewall/login/stuff).

## Config example

```yml
wgportal_config:
  admin_user: <admin user>
  admin_password: <initial admin password, will be saved in plain text but can be changed later in the UI>
  site_title: <config site title>
  site_company_name: <more config site decoration>
  ports: 51820
  external_url: <set the config site access url here>
  encryption_passphrase: <add salt for extra flavor>
```