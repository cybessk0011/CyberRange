#!/bin/bash

sudo umount /dev/nvme0n1p2
sudo vgcreate Cinder /dev/nvme0n1p2

sudo apt update && sudo apt upgrade -y
sudo apt install -y python3-dev python3-venv libffi-dev gcc libssl-dev git

python3 -m venv $HOME/kolla-openstack
source $HOME/kolla-openstack/bin/activate

pip install -U pip
pip install 'ansible<2.10'

echo "[defaults]" > $HOME/ansible.cfg
echo "host_key_checking=False" >> $HOME/ansible.cfg
echo "pipelining=True" >> $HOME/ansible.cfg
echo "forks=100" >> $HOME/ansible.cfg

source $HOME/kolla-openstack/bin/activate
pip install kolla-ansible

sudo mkdir /etc/kolla
sudo chown $USER:$USER /etc/kolla

cp $HOME/kolla-openstack/share/kolla-ansible/etc_examples/kolla/* /etc/kolla/
cp $HOME/kolla-openstack/share/kolla-ansible/ansible/inventory/all-in-one .

echo "---" > /etc/kolla/globals.yml
echo "config_strategy: \"COPY_ALWAYS\"" >> /etc/kolla/globals.yml
echo "kolla_base_distro: \"ubuntu\"" >> /etc/kolla/globals.yml
echo "kolla_install_type: \"source\"" >> /etc/kolla/globals.yml
echo "openstack_release: \"victoria\"" >> /etc/kolla/globals.yml
echo "kolla_internal_vip_address: \"192.168.1.223\"" >> /etc/kolla/globals.yml
echo "kolla_internal_fqdn: \"stack.lab.internal\"" >> /etc/kolla/globals.yml
echo "kolla_external_vip_address: \"{{ kolla_internal_vip_address }}\"" >> /etc/kolla/globals.yml
echo "kolla_external_fqdn: \"{{ kolla_internal_fqdn }}\"" >> /etc/kolla/globals.yml
echo "network_interface: \"eno1\"" >> /etc/kolla/globals.yml
echo "neutron_external_interface: \"enx000acd317214\"" >> /etc/kolla/globals.yml
echo "neutron_plugin_agent: \"openvswitch\"" >> /etc/kolla/globals.yml
echo "enable_haproxy: \"yes\"" >> /etc/kolla/globals.yml
echo "enable_cinder: \"yes\"" >> /etc/kolla/globals.yml
echo "cinder_volume_group: \"Cinder\"" >> /etc/kolla/globals.yml
echo "enable_cinder_backend_lvm: \"yes\"" >> /etc/kolla/globals.yml
echo "keystone_token_provider: 'fernet'" >> /etc/kolla/globals.yml
echo "nova_compute_virt_type: \"qemu\"" >> /etc/kolla/globals.yml

source $HOME/kolla-openstack/bin/activate
kolla-genpwd

source $HOME/kolla-openstack/bin/activate
kolla-ansible -i all-in-one bootstrap-servers

source $HOME/kolla-openstack/bin/activate
kolla-ansible -i all-in-one prechecks

source $HOME/kolla-openstack/bin/activate
kolla-ansible -i all-in-one deploy