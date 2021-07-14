#!/bin/bash

source ~/kolla-openstack/bin/activate
kolla-ansible -i all-in-one stop --yes-i-really-really-mean-it

sudo rm -rf $HOME/kolla-openstack
sudo rm -rf /etc/kolla

sudo reboot
