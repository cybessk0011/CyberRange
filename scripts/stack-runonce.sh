#!/bin/bash

source $HOME/kolla-openstack/bin/activate

pip install python-openstackclient python-neutronclient python-glanceclient

kolla-ansible post-deploy
source /etc/kolla/admin-openrc.sh
nano kolla-openstack/share/kolla-ansible/init-runonce
kolla-openstack/share/kolla-ansible/init-runonce