# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.require_version ">= 1.5.0"

# Read YAML file with cluster details
cluster = YAML.load_file('cluster.yaml')

NUM_INSTANCES = Integer(cluster['num_nodes'])

BASE_IP_ADDR = ENV['BASE_IP_ADDR'] || String(cluster['ip_addr_prefix'])
ETCD_DISCOVERY = "#{BASE_IP_ADDR}.101"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = String(cluster['box'])
  # config.vm.box_version = ">= 0.4.0"

  config.vm.define "discovery" do |discovery|
    discovery.vm.hostname = String(cluster['discovery']['name'])

    discovery.vm.network :private_network, ip: ETCD_DISCOVERY

    discovery.vm.provider :virtualbox do |v|
      v.memory = Integer(cluster['discovery']['memory'])
      v.cpus = Integer(cluster['discovery']['cpus'])
      v.gui = cluster['virtualbox']['gui']
    end
    discovery.vm.provider :parallels do |v|
      v.memory = Integer(cluster['discovery']['memory'])
      v.cpus = Integer(cluster['discovery']['cpus'])
    end

    discovery.vm.provision :file, source: "./discovery", destination: "/tmp/vagrantfile-user-data"
    # UTC (default) is a no-op
    if String(cluster['timezone']) != "UTC"
      discovery.vm.provision :file, source: "./timezone", destination: "/tmp/timezone"
    end

    discovery.vm.provision :shell do |sh|
      sh.privileged = true
      sh.inline = <<-EOT
        if [ -f /tmp/timezone ]; then
          sed -e "s,%%timezone%%,#{cluster['timezone']},g" -i /tmp/timezone
        fi
        cat /tmp/timezone >> /tmp/vagrantfile-user-data
        rm -rf /tmp/timezone
        mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/
      EOT
    end
  end

  (1..NUM_INSTANCES).each do |i|
    config.vm.define String(cluster['node_specs']['prefix']) + "-#{i}" do |core|
      core.vm.hostname = String(cluster['node_specs']['prefix']) + "-#{i}"

      core.vm.network :forwarded_port, guest: 4001, host: "400#{i}".to_i

      core.vm.network :private_network, ip: "#{BASE_IP_ADDR}.#{i+1}"

      core.vm.provider :virtualbox do |v|
        v.memory = Integer(cluster['node_specs']['memory'])
        v.cpus = Integer(cluster['node_specs']['cpus'])
        v.gui = cluster['virtualbox']['gui']
      end
      core.vm.provider :parallels do |v|
        v.memory = Integer(cluster['node_specs']['memory'])
        v.cpus = Integer(cluster['node_specs']['cpus'])
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
