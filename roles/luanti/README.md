# Luanti role

Host a luanti server with all the configured mods. It also hosts a mapserver on the side if configured to do so.

Built using Fedora's community luanti server as a base

https://pagure.io/fedora-mine/

Expects to run on a Fedora system

## Config example

```yml

# Luanti Mode
luanti_config:
  game:
    name: mineclone2
    url: https://content.luanti.org/uploads/bf06e78d80.zip
    user_password: 12345
    mods:
    - name: mapserver
      url: https://content.luanti.org/uploads/8593934e95.zip
    - name: whitelist
      url: https://content.luanti.org/uploads/3856ecc059.zip
    - name: xban2
      url: https://content.luanti.org/uploads/14be84e5ee.zip
    - name: illumination
      url: https://content.luanti.org/uploads/65d28de215.zip
      # whitelist deps
    - name: lib_chatcmdbuilder
      url: https://content.luanti.org/uploads/e34ab089d8.zip

  world:
    id: openserver
    name: An open server
    description: Wow! can't beleive it's real
    host: "<a host>"
    url: "<an url>"
    admin_name: "<a name>"
    announce: false
    port: 30000
    settings:
    - enable_minimap = true
    - mapserver.enable_crafting = true
    - mapserver.send_interval = 10
    - secure.http_mods = mapserver
    - mapserver.url = http://127.0.0.1:8080
    - enable_rollback_recording = true

  mapserver:
    port: 8080
```