virtualbox: clean
	vagrant up

parallels: clean
	vagrant up --provider parallels --no-parallel

clean:
	vagrant destroy -f

.PHONY: clean
