Podman-Role for Container-Setup
=========

This role sets up containers using Podman and can create a OVS GENEVE Overlay-Network for a specified host group if needed.


Role Variables
--------------

The needed variables are in the defaults directory of this role.


Example Playbook
----------------


    - hosts: galera.podman
      remote_user: root
      gather_facts: yes

      roles:
         - podman

