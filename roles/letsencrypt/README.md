zjleblanc.utils.letsencrypt
=========

Generate Let's Encrypt certificates and verify via http-01 or dns-01 challenge.

[Issue Tracker](https://github.com/zjleblanc/zjleblanc.utils/issues)

Minimum Ansible Version: 2.1

Galaxy Tags: \[ acme letsencrypt ssl certificates cloudflare \]

Required Variables
------------------

| Name | Example | Description |
| -------- | ------- | ------------------- |
| letsencrypt_email | acme@example.com |  |
| letsencrypt_domain_name | example.autodotes.com | Used for CN of certificate (base or subdomain) |
| letsencrypt_base_domain_name | autodotes.com | Base domain |
| letsencrypt_challenge_type | `http_01` \| `dns_01` | Either http_01 or dns_01 |


Role Variables
--------------

| Variable | Type | Value or Expression | Description |
| -------- | ------- | ------------------- | --------- |
| letsencrypt_directory | default | https://acme-v02.api.letsencrypt.org/directory |  |
| letsencrypt_version | default | 2 |  |
| letsencrypt_dir | default | /etc/letsencrypt |  |
| letsencrypt_keys_dir | default | {{ letsencrypt_dir }}/keys |  |
| letsencrypt_csrs_dir | default | {{ letsencrypt_dir }}/csrs |  |
| letsencrypt_certs_dir | default | {{ letsencrypt_dir }}/certs |  |
| letsencrypt_account_key | default | {{ letsencrypt_dir }}/account/account.key |  |
| letsencrypt_force_renew | default | false | If true, will bypass condition for expiration <30 days |
| letsencrypt_http01_webroot | default | /var/www/html |  |
| letsencrypt_dns01_provider | default | cloudflare | Only supported provider |

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

  ```yaml
    - hosts: servers
      tasks:
        - name: Create Let's Encrypt certificate
          ansible.builtin.include_role:
            name: zjleblanc.utils.letsencrypt
          vars:
            letsencrypt_email: acme@example.com
            letsencrypt_domain_name: example.autodotes.com
            letsencrypt_base_domain_name: autodotes.com # needed for dns challenge
            letsencrypt_challenge_type: dns_01
  ```

License
-------

MIT

Author Information
-------
**Zachary LeBlanc**

Red Hat
