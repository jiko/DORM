Debian + OpenResty + MySQL
==========================

Couldn't resist the acronym. Includes the [TechEmpower benchmark app](https://github.com/TechEmpower/FrameworkBenchmarks/tree/master/openresty), but with a configuration file that's closer to the OpenResty default and some Lua for debugging MySQL.

    vagrant up

[installs OpenResty with LuaJIT](http://openresty.org/#Installation) and [MySQL 5.5](http://dev.mysql.com/doc/refman/5.5/en/) on a [Vagrant box](http://www.vagrantup.com/) with a [Debian 7.2 base](http://www.debian.org/News/2013/20131012). I prefer Debian, but you might want to [pick a different](http://cloud-images.ubuntu.com/vagrant/) [base box](vagrantbox.es), or run the scripts without Vagrant. This repository duplicates much of my [OpenResty-Vagrant repo](https://github.com/jiko/OpenResty-Vagrant). I have not tested the scripts outside of this Vagrant configuration. 

If you want a pre-packaged box built from this repository, do:

    vagrant box add debian7-openresty https://www.dropbox.com/s/f3dy8m7j75oyk7g/dorm.box

Next step: [Getting Started with OpenResty](http://openresty.org/#GettingStarted)
