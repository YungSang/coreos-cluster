# base cluster definitions
BASE_IP_ADDR ?= 192.168.65
NUM_INSTANCES ?= 3
CHANNEL ?= coreos
# baseline memory
BASE_MEMORY ?= 1024
BASE_CPUS ?= 1
# etcd/discovery VM
DISCOVERY_MEMORY ?= $(BASE_MEMORY)
DISCOVERY_CPUS ?= $(BASE_CPUS)
# CoreOS compute nodes
PER_NODE_MEMORY ?= $(BASE_MEMORY)
PER_NODE_CPUS ?= $(BASE_CPUS)

export BASE_IP_ADDR NUM_INSTANCES CHANNEL
export BASE_CPUS BASE_MEMORY
export DISCOVERY_CPUS DISCOVERY_MEMORY
export PER_NODE_CPUS PER_NODE_MEMORY

virtualbox: clean
	vagrant up

parallels: clean
	vagrant up --provider parallels --no-parallel

clean:
	vagrant destroy -f

.PHONY: clean
