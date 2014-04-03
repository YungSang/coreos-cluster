# CoreOS Cluster Setup with Vagrant

This will setup [CoreOS](https://coreos.com/) cluster environment with [Vagrant](http://www.vagrantup.com/).

```
$ git clone https://github.com/YungSang/coreos-cluster
$ cd coreos-cluster
$ vagrant up
```

## Play with Etcd

- Download etcdctl from [https://github.com/coreos/etcd/releases](https://github.com/coreos/etcd/releases)

```
$ etcdctl ls
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

- Download fleetctl from [https://github.com/coreos/fleet/releases](https://github.com/coreos/fleet/releases)

```
$ fleetctl list-machines
MACHINE		IP				METADATA
d760866b...	192.168.65.2	-
6d1a752c...	192.168.65.3	-
39959ae3...	192.168.65.4	-
$ fleetctl list-units
UNIT	LOAD	ACTIVE	SUB		DESC	MACHINE
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

You may need the following configurations to use `fleetctl status/ssh`.

```[]()
$ vagrant ssh-config core-1 | sed -n "s/IdentityFile//gp" | xargs ssh-add
$ export FLEETCTL_TUNNEL="$(vagrant ssh-config core-1 | sed -n "s/[ ]*HostName[ ]*//gp"):$(vagrant ssh-config core-1 | sed -n "s/[ ]*Port[ ]*//gp")"
```
Cf.) [https://github.com/coreos/fleet/blob/master/Documentation/remote-access.md#vagrant](https://github.com/coreos/fleet/blob/master/Documentation/remote-access.md#vagrant)

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
$ fleetctl ssh -u hello.service
   ______                ____  _____
  / ____/___  ________  / __ \/ ___/
 / /   / __ \/ ___/ _ \/ / / /\__ \
/ /___/ /_/ / /  /  __/ /_/ /___/ /
\____/\____/_/   \___/\____//____/
core@core-1 ~ $ 
```

Cf.) [Controlling the Cluster with fleetctl](https://coreos.com/docs/launching-containers/launching/fleet-using-the-client/)

## License

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)  
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
