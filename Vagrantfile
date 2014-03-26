# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

NUM_INSTANCES = 3

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  (1..NUM_INSTANCES).each do |i|
    config.vm.define "core-#{i}" do |core|
      vm_name = "core-#{i}"
      ip_addr = "192.168.65.#{i+1}"

      if i == 1
        peers = ""
      else
        peers = "-peers 192.168.65.2:7001"
      end

      core.vm.box = "yungsang/coreos"

      core.vm.hostname = vm_name

      core.vm.network "forwarded_port", guest: 4001, host: "400#{i}".to_i

      core.vm.network :private_network, ip: ip_addr

      core.vm.provision :file, source: "units/", destination: "/tmp"

      core.vm.provision :shell do |sh|
        sh.inline = <<-EOT
          sudo rm -rf /home/core/etcd/
          sudo cp /tmp/units/etcd-cluster.service /media/state/units/
          sudo sed -e "s/%IP_ADDR%/#{ip_addr}/g" -i /media/state/units/etcd-cluster.service
          sudo sed -e "s/%NAME%/#{vm_name}/g" -i /media/state/units/etcd-cluster.service
          sudo sed -e "s/%PEERS%/#{peers}/g" -i /media/state/units/etcd-cluster.service
          sudo systemctl stop etcd
          sudo systemctl enable --runtime /media/state/units/etcd-cluster.service
          sudo systemctl daemon-reload
          sudo systemctl start etcd-cluster
          sudo systemctl start fleet
        EOT
      end
    end
  end
end