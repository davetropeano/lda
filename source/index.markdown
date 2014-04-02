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
