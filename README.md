# CoreOS Cluster Setup with Vagrant

This will setup [CoreOS](https://coreos.com/) cluster environment with [Vagrant](http://www.vagrantup.com/).

```
$ git clone https://github.com/YungSang/coreos-cluster
$ cd coreos-cluster
$ vagrant up
```

## Play with Fleet

- Download fleetctl from [https://github.com/coreos/fleet/releases](https://github.com/coreos/fleet/releases)
- Download example services from [https://github.com/coreos/fleet/tree/master/examples](https://github.com/coreos/fleet/tree/master/examples)

```
$ fleetctl list-machines
$ fleetctl list-units
$ fleetctl submit hello.service
$ fleetctl start hello.service
```

You may need the following configurations to use `fleetctl status/ssh`.

```[]()
$ vagrant ssh-config core-1 | sed -n "s/IdentityFile//gp" | xargs ssh-add
$ export FLEETCTL_TUNNEL="$(vagrant ssh-config core-1 | sed -n "s/[ ]*HostName[ ]*//gp"):$(vagrant ssh-config core-1 | sed -n "s/[ ]*Port[ ]*//gp")"
```
Cf.) [https://github.com/coreos/fleet/blob/master/Documentation/remote-access.md#vagrant](https://github.com/coreos/fleet/blob/master/Documentation/remote-access.md#vagrant)

```
$ fleetctl status hello.service
$ fleetctl ssh -u hello.service
```

Cf.) [Controlling the Cluster with fleetctl](https://coreos.com/docs/launching-containers/launching/fleet-using-the-client/)

## License

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)  
To the extent possible under law, the person who associated CC0 with this work has waived all copyright and related or neighboring rights to this work.
