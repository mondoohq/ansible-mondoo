# Mondoo Package Ansible Role

![mondoo ansible role illustration](.github/social/preview.jpg)

## Overview

This role installs `cnquery` and `cnspec` on Linux and Windows servers.

It does:

- Installs the signed `cnquery` and `cnspec` binaries
- Registers `cnquery` and `cnspec` with Mondoo Platform
- Enables the `cnspec` service on Linux and Windows

It supports:

- Amazon Linux
- Debian
- Red Hat Enterprise Linux and derivatives (CentOS/AlmaLinux/Rocky Linux)
- SUSE & openSUSE
- Ubuntu
- Windows 10, 11, 2016, 2019, 2022

The role is published at Ansible Galaxy: [Mondoo/Client role](https://galaxy.ansible.com/mondoo/client).

## Requirements

- Ansible > 2.5

## Role Variables

| Name                           | Default Value | Description                                                                                                                         |
| ------------------------------ | ------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `registration_token_retrieval` | `manual`      | `manual` requires to set ``registration_token` |
| `registration_token`           | n/a           | manually set the Mondoo Platform Registration Token that is used to register `cnquery` and `cnspec` |
| `force_registration`           | false         | forces re-registration for each run                                                                                                 |

## Dependencies

This role has no role dependencies

## Example: Apply Ansible Playbook to Amazon EC2 Linux instance

This playbook demonstrates how to use the Mondoo Package role to install `cnquery` and `cnspec` on many instances:

1. Create a new `hosts` inventory. Add your host to the group.

```ini
[linux_hosts]
54.172.7.243  ansible_user=ec2-user
```

2. Create a `playbook.yml` and change the `registration_token`:

```yaml
---
- hosts: linux_hosts
  become: yes
  roles:
    - role: mondoohq.client
      vars:
        registration_token: "changeme"
```

In addition we support the following variables:

| variable                      | description                                                               |
|-------------------------------|---------------------------------------------------------------------------|
| `force_registration: true`    | set to true if you want to re-register `cnquery` and `cnspec`             |
| `ensure_managed_client: true` | ensures the configured clients are configured as managed Client in Mondoo |
| `proxy_env['https_proxy']`    | set the proxy for the `cnspec` client                                     |
| `annotations`                 | set annotations/ tags for the node                                        |

```yaml
---
- hosts: linux_hosts
  become: yes
  roles:
    - role: mondoohq.client
      vars:
        registration_token: "changeme"
        force_registration: true
        ensure_managed_client: true
        annotations: "owner=hello@mondoo.com,env=production"
```

If you want to use cnspec behind a proxy

```yaml
---
- hosts: linux_hosts
  become: yes
  vars:
    proxy_env:
      http_proxy: "http://192.168.56.1:3128"
      https_proxy: "http://192.168.56.1:3128"

  roles:
    - role: mondoohq.client
      vars:
        registration_token: "changeme"
        force_registration: true
        ensure_managed_client: true
      environment: "{{proxy_env}}"
```

1. Run the playbook with the local hosts file

```bash
# download mondoo role
ansible-galaxy install mondoohq.client
# apply the playbook
ansible-playbook -i hosts playbook.yml
```

4. Log into the [Mondoo Console](https://console.mondoo.com) to view the scan results

## Apply Ansible Playbook to Amazon EC2 Windows instance

If you are using Windows, please read the ansible documentation about [WinRM setup](https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html#id4) or the [SSH setup](https://docs.ansible.com/ansible/latest/user_guide/windows_setup.html#windows-ssh-setup).

1. Create a new `hosts` inventory. Add your host to the group.

```ini
[windows_hosts]
123.123.247.76 ansible_port=5986 ansible_connection=winrm ansible_user=Administrator ansible_password=changeme ansible_shell_type=powershell ansible_winrm_server_cert_validation=ignore
```

or if you are going to use ssh:

```ini
3.235.247.76 ansible_port=22 ansible_connection=ssh ansible_user=admin ansible_shell_type=cmd
```

2. Create a `playbook.yml` and change the `registration_token`:

If you are targeting windows, the configuration is slightly different since `become` needs to be deactivated:

```yaml
- hosts: windows_hosts
  roles:
    - role: mondoohq.client
      vars:
        registration_token: "changeme"
        force_registration: false
```

3. Run the playbook with the local hosts file

```bash
# download mondoo role
ansible-galaxy install mondoohq.client
# apply the playbook
ansible-playbook -i hosts playbook.yml
```

## Testing

For testing, this role uses molecule. You can install the dependencies via:

```bash
pip install molecule
pip install docker
pip install 'molecule[docker]'
```

The `molecule` cli covers the test lifecycle:

```bash
# reset molecule
molecule reset
# converge the machines with ansible
image=geerlingguy/docker-ubuntu2204-ansible molecule converge
# run molecule tests with cnspec
image=geerlingguy/docker-ubuntu2204-ansible molecule verify
# for debugging, you can login to individual hosts
molecule login --host ubuntu
# destroy the test setup
molecule destroy
```

```
image=geerlingguy/docker-ubuntu2204-ansible molecule test
image=rsprta/opensuse-ansible molecule test
```

NOTE: to be able to test on m1 macOS, you need arm compatible docker images like rockylinux shown above

For linting, we use `ansible-lint`:

```bash
pip3 install ansible-lint
```

Then you can see all local issues with:

```
ansible-lint
```

## Author

Mondoo, Inc

## FAQ

**Error 'module' object has no attribute 'HTTPSHandler'**

```
TASK [mondoo : Download Mondoo RPM key] ********************************
    fatal: [suse]: FAILED! => {"changed": false, "module_stderr": "Shared connection to 127.0.0.1 closed.\r\n", "module_stdout": "Traceback (most recent call last):\r\n  File \"/home/vagrant/.ansible/tmp/ansible-tmp-1562450830.52-85510064926638/AnsiballZ_get_url.py\", line 113, in <module>\r\n    _ansiballz_main()\r\n  File \"/home/vagrant/.ansible/tmp/ansible-tmp-1562450830.52-85510064926638/AnsiballZ_get_url.py\", line 105, in _ansiballz_main\r\n    invoke_module(zipped_mod, temp_path, ANSIBALLZ_PARAMS)\r\n  File \"/home/vagrant/.ansible/tmp/ansible-tmp-1562450830.52-85510064926638/AnsiballZ_get_url.py\", line 48, in invoke_module\r\n    imp.load_module('__main__', mod, module, MOD_DESC)\r\n  File \"/tmp/ansible_get_url_payload_103dVU/__main__.py\", line 308, in <module>\r\n  File \"/tmp/ansible_get_url_payload_103dVU/ansible_get_url_payload.zip/ansible/module_utils/urls.py\", line 346, in <module>\r\nAttributeError: 'module' object has no attribute 'HTTPSHandler'\r\n", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 1}
```

```
sudo zypper install python python2-urllib3 python3 python3-urllib3
```

**Error `ansible.legacy.setup` on Windows with SSH**

```
fatal: [123.123.247.76]: FAILED! => {"ansible_facts": {}, "changed": false, "failed_modules": {"ansible.legacy.setup": {"failed": true, "module_stderr": "Parameter format not correct - ;\r\n", "module_stdout": "", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 1}}, "msg": "The following modules failed to execute: ansible.legacy.setup\n"}
```

Ansible in combination with Win32-OpenSSH versions older than v7.9.0.0p1-Beta do not work when `powershell` is the shell type, set the shell type to `cmd`


**Error: `You need to install 'jmespath' prior to running json_query filter"`**

Make sure jmespath is installed in the same python environment as ansible:

```bash
pip install jmespath
```

**I want to test it with an unsupported OS**

Add the following to main.yml and print the ansible_facts to see what is used and adjust the `when` conditions:

```yaml
- name: Print all available facts
  ansible.builtin.debug:
    var: ansible_facts
```

## Join the community!

Join the [Mondoo Community GitHub Discussions](https://github.com/orgs/mondoohq/discussions) to collaborate on policy as code and security automation.
