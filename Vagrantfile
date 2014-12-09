# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.5.0"

NUM_INSTANCES = Integer(ENV['NUM_INSTANCES'] || '3')
BASE_IP_ADDR = ENV['BASE_IP_ADDR'] || "192.168.65"
ETCD_DISCOVERY = "#{BASE_IP_ADDR}.101"

BASE_MEMORY = Integer(ENV['BASE_MEMORY'].to_i || '1024')
BASE_CPUS = Integer(ENV['BASE_CPUS'].to_i || '1')

DISCOVERY_MEMORY = Integer(ENV['DISCOVERY_MEMORY'].to_i || '1024')
DISCOVERY_CPUS = Integer(ENV['DISCOVERY_CPUS'].to_i || '1')

PER_NODE_MEMORY = Integer(ENV['PER_NODE_MEMORY'].to_i || '1024')
PER_NODE_CPUS = Integer(ENV['PER_NODE_CPUS'].to_i || '1')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "yungsang/%s" % (ENV['CHANNEL'] || "coreos")

  config.vm.box_version = ">= 0.4.0"

  config.vm.define "discovery" do |discovery|
    discovery.vm.hostname = "discovery"

    discovery.vm.network :private_network, ip: ETCD_DISCOVERY

    discovery.vm.provider :vmware_fusion do |v|
      v.vmx["memsize"] = "#{DISCOVERY_MEMORY}"
      v.vmx["numvcpus"] = "#{DISCOVERY_CPUS}"
    end
    discovery.vm.provider :virtualbox do |v|
      v.memory = "#{DISCOVERY_MEMORY}"
      v.cpus = "#{DISCOVERY_CPUS}"
    end
    discovery.vm.provider :parallels do |v|
      v.memory = "#{DISCOVERY_MEMORY}"
      v.cpus = "#{DISCOVERY_CPUS}"
    end

    discovery.vm.provision :file, source: "./discovery", destination: "/tmp/vagrantfile-user-data"

    discovery.vm.provision :shell do |sh|
      sh.privileged = true
      sh.inline = <<-EOT
        mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/
      EOT
    end
  end

  (1..NUM_INSTANCES).each do |i|
    config.vm.define "core-#{i}" do |core|
      core.vm.hostname = "core-#{i}"

      core.vm.network :forwarded_port, guest: 4001, host: "400#{i}".to_i

      core.vm.network :private_network, ip: "#{BASE_IP_ADDR}.#{i+1}"

      core.vm.provider :vmware_fusion do |v|
        v.vmx["memsize"] = "#{PER_NODE_MEMORY}"
        v.vmx["numvcpus"] = "#{PER_NODE_CPUS}"
      end
      core.vm.provider :virtualbox do |v|
        v.memory = "#{PER_NODE_MEMORY}"
        v.cpus = "#{PER_NODE_CPUS}"
      end
      core.vm.provider :parallels do |v|
        v.memory = "#{PER_NODE_MEMORY}"
        v.cpus = "#{PER_NODE_CPUS}"
      end

      core.vm.provision :file, source: "./user-data", destination: "/tmp/vagrantfile-user-data"

      core.vm.provision :shell do |sh|
        sh.privileged = true
        sh.inline = <<-EOT
          sed -e "s/%NAME%/core-#{i}/g" -i /tmp/vagrantfile-user-data
          sed -e "s/%ETCD_DISCOVERY%/#{ETCD_DISCOVERY}/g" -i /tmp/vagrantfile-user-data
          mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/
        EOT
      end
    end
  end
end
