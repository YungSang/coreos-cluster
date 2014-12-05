# CoreOS Cluster Setup with Vagrant

This will setup [CoreOS](https://coreos.com/) cluster environment with [Vagrant](http://www.vagrantup.com/).

```
$ git clone https://github.com/YungSang/coreos-cluster
$ cd coreos-cluster
$ vagrant up
```

## Play with Etcd

- Requirement: [etcdctl](https://github.com/coreos/etcd/releases)

- Check Etcd status

	```
	$ etcdctl ls
	```

	***You may need the following configurations.***

	```
	$ export ETCDCTL_PEERS="$(vagrant ssh-config core-1 | sed -n "s/[ ]*HostName[ ]*//gp"):4001"
	```

	***etcdctl < v0.4.5***

	```
	$ etcdctl -C "${ETCDCTL_PEERS}" ls
	```

	***etcdctl >= v0.4.5 supports ETCDCTL_PEERS env variable***  
	Cf.) https://github.com/coreos/etcdctl/pull/95/files


- Test writing and reading

	```
	$ etcdctl set /services/test test
	$ etcdctl ls --recursive
	/services
	/services/test
	$ etcdctl get /services/test
	test
	$ vagrant ssh core-3 -c "etcdctl get /services/test"
	test
	```

## Play with Fleet

Cf.) [Controlling the Cluster with fleetctl](https://coreos.com/docs/launching-containers/launching/fleet-using-the-client/)

- Requirement: [fleetctl](https://github.com/coreos/fleet/releases)

- Prepare

	***You may need to reset ~/.fleetctl/known_hosts.***

	```
	$ rm ~/.fleetctl/known_hosts
	```

	***You may need the following configurations.***

	```
	$ vagrant ssh-config core-1 | sed -n "s/IdentityFile//gp" | xargs ssh-add
	$ export FLEETCTL_TUNNEL="$(vagrant ssh-config core-1 | sed -n "s/[ ]*HostName[ ]*//gp"):$(vagrant ssh-config core-1 | sed -n "s/[ ]*Port[ ]*//gp")"
	```

	Cf.) [Remote fleet Access for Vagrant](https://github.com/coreos/fleet/blob/master/Documentation/remote-access.md#vagrant)

- Check Fleet status

	```
	$ fleetctl list-machines
	MACHINE		IP				METADATA
	d760866b...	192.168.65.2	-
	6d1a752c...	192.168.65.3	-
	39959ae3...	192.168.65.4	-
	$ fleetctl list-units
	UNIT	LOAD	ACTIVE	SUB		DESC	MACHINE
	```

- Deplay hello.service

	```
	$ curl -LO https://raw.github.com/coreos/fleet/master/examples/hello.service
	$ fleetctl submit hello.service
	$ fleetctl list-units
	UNIT			LOAD	ACTIVE	SUB	DESC		MACHINE
	hello.service	-		-		-	Hello World	-
	$ fleetctl start hello.service
	$ fleetctl list-units
	UNIT			LOAD	ACTIVE	SUB		DESC		MACHINE
	hello.service	loaded	active	running	Hello World	d760866b.../192.168.65.2
	```

- Check the status and login to the VM where the servise runs  

	```
	$ fleetctl status hello.service
	hello.service - Hello World
	   Loaded: loaded (/run/systemd/system/hello.service; enabled-runtime)
	   Active: active (running) since Sat 2014-03-29 16:10:17 UTC; 58s ago
	 Main PID: 3237 (bash)
	   CGroup: /system.slice/hello.service
	           ├─3237 /bin/bash -c while true; do echo "Hello, world"; sleep 1; done
	           └─3305 sleep 1
	
	Mar 29 16:11:06 core-1 bash[3237]: Hello, world
	Mar 29 16:11:07 core-1 bash[3237]: Hello, world
	Mar 29 16:11:08 core-1 bash[3237]: Hello, world
	Mar 29 16:11:09 core-1 bash[3237]: Hello, world
	Mar 29 16:11:10 core-1 bash[3237]: Hello, world
	Mar 29 16:11:11 core-1 bash[3237]: Hello, world
	Mar 29 16:11:12 core-1 bash[3237]: Hello, world
	Mar 29 16:11:13 core-1 bash[3237]: Hello, world
	Mar 29 16:11:14 core-1 bash[3237]: Hello, world
	Mar 29 16:11:15 core-1 bash[3237]: Hello, world
	$ fleetctl ssh -unit hello.service
	   ______                ____  _____
	  / ____/___  ________  / __ \/ ___/
	 / /   / __ \/ ___/ _ \/ / / /\__ \
	/ /___/ /_/ / /  /  __/ /_/ /___/ /
	\____/\____/_/   \___/\____//____/
	core@core-1 ~ $ 
	```

## Ambassador Pattern

![](http://coreos.com/assets/images/media/etcd-ambassador-hosts.png)

Cf.) [Dynamic Docker links with an ambassador powered by etcd](http://coreos.com/blog/docker-dynamic-ambassador-powered-by-etcd/)

- Clear the previous service unit

	```
	$ fleetctl destroy hello.service
	$ fleetctl list-units
	UNIT	LOAD	ACTIVE	SUB		DESC	MACHINE
	```

- Get services for Ambassador Pattern

	```
	$ git clone git@github.com:YungSang/fleet-redis-demo.git ambassador
	```

- Deploy service units with Fleet

	```
	$ fleetctl start ambassador/*.service
	$ fleetctl list-units
	UNIT						LOAD	ACTIVE	SUB		DESC					MACHINE
	etcd-amb-redis.service		loaded	active	running	Ambassador on A			a7175ced.../192.168.65.2
	etcd-amb-redis2.service		loaded	active	running	Ambassador on B			bbeb5e27.../192.168.65.3
	redis-demo.service			loaded	active	running	Redis on A				a7175ced.../192.168.65.2
	redis-docker-reg.service	loaded	active	running	Register on A			a7175ced.../192.168.65.2
	redis-dyn-amb.service		loaded	active	running	Etcd Ambassador on B	bbeb5e27.../192.168.65.3
	```

- Make sure the services has been started successfully  
(It will take some time to complete.)

	```
	$ etcdctl ls --recursive
	/services
	/services/redis-A
	/services/redis-A/redis-demo.service
	$ etcdctl get /services/redis-A/redis-demo.service
	{ "port": 49153, "host": "192.168.65.2" }
	```

- Check links from Host B to Redis on Host A

	```
	$ fleetctl ssh -unit redis-dyn-amb.service
	   ______                ____  _____
	  / ____/___  ________  / __ \/ ___/
	 / /   / __ \/ ___/ _ \/ / / /\__ \
	/ /___/ /_/ / /  /  __/ /_/ /___/ /
	\____/\____/_/   \___/\____//____/
	core@core-2 ~ $ docker run -i -t --link redis-dyn-amb.service:redis shopigniter/redis-cli -h redis
	Pulling repository shopigniter/redis-cli
	.
	.
	.
	redis:6379> ping
	PONG
	redis:6379> exit
	core@core-2 ~ $ 
	```

## License

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)  
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
