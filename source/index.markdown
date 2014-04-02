---
layout: page
title: "Getting Started"
date: 2014-03-28 09:04
comments: true
sharing: true
footer: true
---
LDA is a light-weight framework that helps developers design and implement integrated
systems composed of multiple applications that follow a REST model and can be deployed
on clouds. An LDA-based application is a run-time subsystem whose communication with the
outside world is entirely through HTTP/REST. This means that the applications
(REST subsystems) cannot see each other directly. They can only see the resources they
expose.

The problem LDA is solving is not implementing individual applications - there are
lots of technologies for that - but rather implementing a coherent system made up of
many applications that talk to each other. Two other common approaches for solving
this problem, a 'central repository' approach and one that in recent years
has come to be called 'SOA', have major scalability issues that we believe the LDA
approach completely overcomes.

The basic idea behind the use of Linked Data for integration is simple.
We have seen that the regular HTML web is an extraordinary integrator.
By embedding links - usually HTML anchor tags - inside pages, HTML
enables the user of a browser to navigate to other pages without modifying
those pages or constraining in any way how those pages are implemented - they
don't even have to be HTML. This integration does not require any sort of
coordination or contract between the owners of the referenced pages and the
owner of the page that references them, except perhaps to demand that the URLs
used to reference the pages should not change or disappear. This extraordinarily
simple idea has allowed the world-wide web to freely integrate
commerce sites, blogs and micro-blogs, music sites, video sites, social
networking sites, government sites, news sites and so on.

The basic idea of integration
using Linked Data is that if you just substitute a data model 
([RDF](http://davetropeano.github.io/lda/what-is-this-rdf-thing/index.html)) for HTML and otherwise
'make like the world-wide web', then applications can achieve the same sort of easy and
limitless integration that we see in the HTML web.
To achieve this goal, ones need to implement client applications that 'make like a browser'
and server applications that expose everything as linked resources. The LDA
framework provides server-side and a client-side components that make it easy to
create applications that follow exactly that pattern.

The server-side component is written in Python,
about 75% of which could be ported to other languages to support application development in
those languages. We have not yet done such ports, so currently you have to write server
applications in Python to use our framework. The rest of the server code takes
the form of subsystems that implement standard system functions - authentication,
access control and multi-tenancy - that are accessed as HTTP resources and so can
remain in Python even on a system that implements applications in other languages.

LDA's client component consists of Javascript libraries containing helper methods
for various common tasks. There is almost no framework code on the client - you can write
your clients using whatever Javascript frameworks you like and still use the LDA libraries.
The libraries simply make it easier to work with data from resources produced by LDA-based servers.

## Getting Started

The easiest way to get started with LDA is to download the framework from github as follows:

1. Create a working directory:
```sh
mkdir ldaprojects # pick your own name
cd ldaprojects
```
1. Clone the github repositories:
```sh
git clone https://github.com/davetropeano/lda-clientlib.git
git clone https://github.com/davetropeano/lda-serverlib.git
git clone https://github.com/davetropeano/lda-siteserver.git
git clone https://github.com/davetropeano/lda-examples.git
```

The four github repositories are now available in the following subdirectories:

1. [lda-clientlib](https://github.com/davetropeano/lda-clientlib/blob/master/README.md) - Javascript libraries for LDA client application development
1. [lda-serverlib](https://github.com/davetropeano/lda-serverlib/blob/master/README.md) - Python libraries for LDA server application development
1. [lda-siteserver](https://github.com/davetropeano/lda-siteserver/blob/master/README.md) - standard system functions for LDA applications - authentication, access control and multi-tenancy
1. [lda-examples](https://github.com/davetropeano/lda-examples/blob/master/README.md) - LDA example applications

There are several sample application in the **lda-examples** repository you can look at and run.
Note that the 4 repositories must be downloaded in sibling directories as instructed above in order to run the examples.

The LDA framework requires a running back-end database for storing the data and an adapter
that matches the database to the REST/RDF assumptions of the application.
The adapter currently available (in **lda-serverlib**) is for
[MongoDB](https://www.mongodb.org/). Rather than installing and running MongoDB yourself,
the **lda-examples** project includes a Vagrantfile that can be used to start a MongoDB server
as well as an Nginx reverse proxy server, needed for some of the examples.

Before you run the examples, you first need to download/install the following:

1. [Vagrant](http://docs.vagrantup.com/v2/installation/)
1. [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
   * Make sure you have a VirtualBox Host-Only Network (IP address 192.168.56.1)
configured (see **Note 1**, below).

Once Vagrant and VirtualBox are installed, execute the following commands:

```sh
cd lda-examples
vagrant up
```

At this point the database server is running and ready for you to start playing with the
[examples](https://github.com/davetropeano/lda-examples).

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
