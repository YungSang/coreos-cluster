BASE_IP_ADDR ?= 192.168.66
export BASE_IP_ADDR

virtualbox: clean
	vagrant up

parallels: clean
	vagrant up --provider parallels --no-parallel

clean:
	vagrant destroy -f

.PHONY: clean
