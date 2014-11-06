virtialbox:
	vagrant destroy -f
	BASE_IP_ADDR="192.168.65" vagrant up

parallels:
	vagrant destroy -f
	BASE_IP_ADDR="192.168.66" vagrant up --provider parallels --no-parallel

clean:
	vagrant destroy -f

.PHONY: clean
