---
layout: page
title: "Downloading The Software"
date: 2014-04-02 13:45
comments: true
sharing: true
footer: true
---
The easiest way to get started with LDA is to download the framework from github as follows:

1. Create a working directory:
```sh
mkdir ld4apps # or pick your own name
cd lda4apps
```
1. Clone the github repositories:
```sh
git clone https://github.com/ld4apps/lda-clientlib.git
git clone https://github.com/ld4apps/lda-serverlib.git
git clone https://github.com/ld4apps/lda-siteserver.git
git clone https://github.com/ld4apps/lda-examples.git
```

The four github repositories should now be in the following subdirectories:

1. [lda-clientlib](https://github.com/ld4apps/lda-clientlib/) - Javascript libraries for LDA client application development
1. [lda-serverlib](https://github.com/ld4apps/lda-serverlib/) - Python libraries for LDA server application development
1. [lda-siteserver](https://github.com/ld4apps/lda-siteserver/) - standard system functions for LDA applications - authentication, access control and multi-tenancy
1. [lda-examples](https://github.com/ld4apps/lda-examples/) - LDA example applications

There are several [sample application](https://github.com/ld4apps/lda-examples/blob/master/README.md)
in the lda-examples repository you can look at and run.
Note that the 4 repositories must be downloaded in sibling directories, as instructed above, in
order to run the examples.

## Setting up Database and Reverse Proxy Servers

The LDA framework requires a running back-end database for storing application data. Most non-trivial LDA
applications also require a reverse proxy web server configured to route requests to appropriate
application subsystems. Currently, LDA uses/supports [MongoDB](https://www.mongodb.org/) for
the database and we usually use Nginx for the reverse proxy server.
Before you can do much with the LDA framework, you will need one or both of these servers to be running.

### Starting MongoDB

If you are getting started with LDA and just want to follow along with the
[Todo Sample Tutorial](/developing-lda-applications/index.html), the fastest way to 
get set up is to simply go to the [MongoDB download page](https://www.mongodb.org/downloads)
and download the appropriate version for your OS.

Once MongoDB has downloaded, execute the following commands:

```sh
cd <mongodb-installation-directory>/bin
mongod
```

At this point, MonoDB should be running and listening on its default host and port (localhost:27017).
You should now be able to run the 'Todo Sample' in the 
[lda-examples](https://github.com/ld4apps/lda-examples) repository.

### Using Vagrant to start MongoDB and Nginx

If you plan to do more with LDA (for example, run all the examples, and start to play with it
yourself) ather than installing and running MongoDB, the 
[lda-examples](https://github.com/ld4apps/lda-examples) repository includes
a Vagrantfile that can be used to start a MongoDB server as well as a properly configured
Nginx reverse proxy server.

Before you can use the supplied Vagrantfile, you first need to download/install the following:

1. [Vagrant](http://docs.vagrantup.com/v2/installation/)
1. [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
   * Make sure you have a VirtualBox Host-Only Network (IP address 192.168.56.1)
configured (see **Note 1**, below).

Once Vagrant and VirtualBox are installed, execute the following commands:

```sh
cd lda-examples
vagrant up
```

At this point the mongodb and nginx servers are running and ready for you to start playing with
all of the [examples](https://github.com/ld4apps/lda-examples). Have fun!

### Note 1. Configure VirtualBox Host-Only Network (IP address 192.168.56.1)

On some machines, the following steps are necessary to configure VirtualBox to work
correctly for SetupShop. This definitely seems to be needed on Mac, but (some?) Windows
machines seem to have this automatically (pre)configured.

1. Start the VirtualBox app and select VirtualBox / Preferences...
2. Click the "Network" tab.
3. Click the "Add host-only network (Ins)" green plus button on the right to add "vboxnet0" to the list of Host-only Networks.
4. Then click on the screwdriver icon on the right hand side to edit the vboxnet0 settings.
5. Accept the default IP address (192.168.56.1) settings on the Adapter tab.
6. Click on the DHCP Server tab.
7. Ensure that "Enable Server" is NOT checked on the DHCP Server tab. Then click "OK" and "OK" to save the settings.
