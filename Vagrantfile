# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.5.0"

NUM_INSTANCES = 3

BASE_IP_ADDR = "192.168.65"
ETCD_LEADER  = "#{BASE_IP_ADDR}.2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "yungsang/coreos"

  config.vm.box_version = ">= 0.3.1"

  (1..NUM_INSTANCES).each do |i|
    config.vm.define vm_name = "core-#{i}" do |core|
      ip_addr = "#{BASE_IP_ADDR}.#{i+1}"
      peers   = "#{ETCD_LEADER}:7001"

      if ip_addr == ETCD_LEADER
        peers = ""
      end

      core.vm.hostname = vm_name

      core.vm.network :forwarded_port, guest: 4001, host: "400#{i}".to_i

      core.vm.network :private_network, ip: ip_addr

      core.vm.provision :file, source: "./user-data", destination: "/tmp/user-data"

      core.vm.provision :shell do |sh|
        sh.privileged = true
        sh.inline = <<-EOT
          sed -e "s/%PEERS%/#{peers}/g" -i /tmp/user-data
          mkdir -p /var/lib/coreos-vagrant
          cp /tmp/user-data /var/lib/coreos-vagrant/
          systemctl daemon-reload
        EOT
      end
    end
  end
end