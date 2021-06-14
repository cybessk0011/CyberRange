#!/bin/bash

#sudo umount /dev/nvme0n1p2
#sudo vgcreate Cinder /dev/nvme0n1p2

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

echo "---" > /etc/kolla/globals.yml
echo "config_strategy: \"COPY_ALWAYS\"" >> /etc/kolla/globals.yml
echo "kolla_base_distro: \"ubuntu\"" >> /etc/kolla/globals.yml
echo "kolla_install_type: \"source\"" >> /etc/kolla/globals.yml
echo "openstack_release: \"victoria\"" >> /etc/kolla/globals.yml
echo "kolla_internal_vip_address: \"192.168.1.10\"" >> /etc/kolla/globals.yml
echo "kolla_internal_fqdn: \"stack-head\"" >> /etc/kolla/globals.yml
echo "kolla_external_vip_address: \"10.65.112.223\"" >> /etc/kolla/globals.yml
echo "kolla_external_fqdn: \"stack.cybereers.internal\"" >> /etc/kolla/globals.yml
#echo "network_interface: \"enp4s0\"" >> /etc/kolla/globals.yml
echo "neutron_external_interface: \"enp5s0\"" >> /etc/kolla/globals.yml
echo "neutron_plugin_agent: \"openvswitch\"" >> /etc/kolla/globals.yml
echo "enable_haproxy: \"no\"" >> /etc/kolla/globals.yml
echo "enable_keepalived: \"no\"" >> /etc/kolla/globals.yml
echo "enable_cinder: \"yes\"" >> /etc/kolla/globals.yml
echo "cinder_volume_group: \"Cinder\"" >> /etc/kolla/globals.yml
echo "enable_cinder_backend_lvm: \"yes\"" >> /etc/kolla/globals.yml
echo "keystone_token_provider: 'fernet'" >> /etc/kolla/globals.yml
echo "nova_compute_virt_type: \"qemu\"" >> /etc/kolla/globals.yml

source $HOME/kolla-openstack/bin/activate
kolla-genpwd

source $HOME/kolla-openstack/bin/activate
kolla-ansible -i multinode bootstrap-servers

source $HOME/kolla-openstack/bin/activate
kolla-ansible -i multinode prechecks

source $HOME/kolla-openstack/bin/activate
kolla-ansible -i multinode deploy