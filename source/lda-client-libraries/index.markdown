---
layout: page
title: "LDA Client Libraries"
date: 2014-03-28 15:09
comments: true
sharing: true
footer: true
---
### ROCA and SPAs
A popular way of writing web applications today is to write what is called a "Single-Page Application" or SPA. The way an SPA works is that a GET on an initial resource on the server will load an HTML program that presents the UI of the resource. This UI program will subsequently load other resources from the server asking for a data-oriented format - usually JSON - so no new HTML will be loaded. As a result, the UI is often more responsive, since there is no need to load new HTML for each resource. SPAs are also often easier to write, because they provide an easy way of preserving the state of the user interaction across resources in the client. This is very important, because the alternatives usually require managing interaction state on the server, which hurts scalability and introduces complexity and performance problems. The use of web technologies to develop mobile applications has given a fillip to SPA designs, since mobile apps are SPAs almost by definition. LDA focuses on the development of SPA clients for both web and mobile.

There is a common perception that SPAs necessarily violate the principles of the resource-oriented architecture that underlies the classic view of the world-wide web - for example, see [ROCA](http://roca-style.org/). We agree with the ROCA principles (which we see as basically a clarification of the core REST architecture of the web) and we agree that many SPAs have the unfortunate characteristic of violating them in various ways, but we do not think it is necessarily so - you just have to learn to write SPAs so that they conform to the rules. The LDA client libraries help implement SPAs that conform.

### How LDA implements SPAs

If the discussion above seems a bit philosophical, an example will probably make it clear. Here is the HTML representation of one of the resources from one of our sample applications:

```html
<!DOCTYPE html>
<html>
<head>
    <script src="/setupshop/application.js" type="text/javascript"></script>
</head>

<body>
    <div graph="http://cloudsupplements.cloudapps4.me/cat/9.3-pain-relief">
        <div resource="http://cloudsupplements.cloudapps4.me/cat/9.3-pain-relief">
            <a property="http://www.w3.org/1999/02/22-rdf-syntax-ns#type" href="http://setupshop.me/ns#Category" ></a>
            <a property="http://ibm.com/ce/ns#lastModifiedBy" href="http://ce-admin-user.name" ></a>
            <a property="http://ibm.com/ce/ns#owner" href="http://ce-admin-user.name" ></a>
            <a property="http://setupshop.me/ns#categoryProducts" href="http://cloudsupplements.cloudapps4.me/cat/9.3-pain-relief/products" ></a>
            <span property="http://purl.org/dc/terms/title" >Pain Relief</span>
            <a property="http://setupshop.me/ns#store" href="http://cloudsupplements.cloudapps4.me/cat/9.4" ></a>
            <a property="http://setupshop.me/ns#image_source" href="http://www.vitalmaxvitamins.com/2011/wp-content/uploads/wpstorecart/foot-balm-new.jpg" ></a>
            <a property="http://ibm.com/ce/ac/ns#resource-group" href="http://cloudsupplements.cloudapps4.me/" ></a>
            <span property="http://ibm.com/ce/ns#modificationCount" datatype="http://www.w3.org/2001/XMLSchema#integer" >0</span>
            <span property="http://ibm.com/ce/ns#lastModified" datatype="http://www.w3.org/2001/XMLSchema#dateTime" >2014-01-15T14:15:41.797000+00:00</span>
            <span property="http://purl.org/dc/terms/created" datatype="http://www.w3.org/2001/XMLSchema#dateTime" >2014-01-15T14:15:41.797000+00:00</span>
            <span property="http://setupshop.me/ns#image_alt_text" >Foot Balm relieves dry-- cracked-- itchy painful feet. Free Shipping On Orders Over $75</span>
            <a property="http://ibm.com/ce/ns#allVersions" href="http://cloudsupplements.cloudapps4.me/cat/9.3-pain-relief/allVersions" ></a>
            <a property="http://purl.org/dc/terms/creator" href="http://ce-admin-user.name" ></a>
        </div>
    </div>
</body>
</html>
```

The first thing you will notice is that most of what you see commonly in HTML is missing - forms, javascript, css and so on. All you see are div, span and anchor elements that encode the data properties of the resource (a 'Category' resource in this case). The format we are using here is RDFa, which we like a lot, but you could use other formats, like the conventions at [schema.org](https://schema.org/) (although our current libraries won't help you read those in your SPA). This representation is attractive for its simplicity, but in practice it is probably a bit too simple. A search engine crawler could get some useful information from this representation, but probably not as much as you would like if you are thinking about search engine optimization (SEO). Our server framework - described later - supports an environment variable you can set to generate more complex HTML that has more information for SEO, but it still does not include the sort of 'HTML UI programming' constructs you will be familiar with from other sites. The UI implementation is included by reference using the following single HTML element:

```
<script src="/setupshop/application.js" type="text/javascript"></script>
```

In this example, /setupshop/application.js happens to be on the same server as the resource itself, but it could actually be anywhere on the web, because it is not specific to any particular data resource.

You might imagine from this that the implementation of our SPA is entirely in Javascript code. We could have implemented it this way, but that has at least two disadvantages:

  1. Developers are used to implementing UI in HTML files
  2. UI implemented in HTML files is easier for 3rd-parties to inspect and learn from

Because of this, /setupshop/application.js really just does a bit of housekeeping (explained below) and then loads a second HTML resource which contains the real SPA implementation. This second HTML file is loaded into the body of the first HTML document to avoid triggering a second HTML document load that would change the address visible to the user and alter the browser history. The second HTML resource contains all the form tags, css and JavaScript that you would expect to find in any 'conventional' HTML file, but it does not contain any resource data, is not specific to any particular resource on our system, and can be anywhere on the web. Looking at the source of the first, data-centric resource will not help you understand the HTML implementation of the UI, but you can easily inspect the second HTML resource using the browser debug tools.

### Why this is important
`
In the HTML representation of each resource, the data of the resource and the implementation of the SPA must both be present, but they must be kept separate
`

The reason the HTML representation must include the data of the resource is that the HTML representation of the resource must be readable by clients other than the browser. The most important of these from a commercial perspective is usually the search engine crawlers, but there are many others.  A common mistake when implementing SPAs is to have an HTML representation of the resource that only includes the SPA implementation, and assume that the SPA will then turn around and load the appropriate data - this approach breaks all clients except the browser.

The reason you must keep the data of the resource separate from SPA implementation is that the same SPA code must be able to display any of the resources it is responsible for as the initial resource displayed to the user. This is what guarantees the correct behaviour on reload, and when typing URLs into browsers. A common mistake in implementing SPAs is to assume that there is a privileged 'initial' resource whose HTML representation will load the SPA and to then intermingle the SPA implementation with the data of this resource.

### Library functions

Once you have understood how this separation enables ROCA-compliant SPAs, you can probably figure out how to implement the rest yourself, but our client libraries contain some functions to make this easier.

When an SPA causes the UI to navigate to the initial resource (the one the user loaded) or navigates between resources, it needs to do it with some care to make sure the ROCA rules will be satisfied. There are really only 3 situations in which an SPA navigates to a resource:

  1. A user clicks on an anchor tag that was created by the SPA in the first place.
  2. A user uses one of the browser history navigation capabilities, like the forward and back buttons.
  3. Javascript that is part of the SPA implementation decides to move to a new resource. This includes the case when a newly-loaded SPA implementation is looking at what the initial data resource was loaded to decide what part of the SPA UI to show.

The client libraries include a standard 'Dispatcher' class that applications can use to unify these 3 cases and provide standard handling of the browser history API.

Here is a list of some of the functions of the client libraries:

1. Provide a dispatcher function that helps SPAs integrate with the browser history and navigation mechanisms in ways that support the ROCA principles.
2. Read HTML representations that contain RDFa (potentially in the future schema.org) information and convert it into Javascript objects that are useful for programming.
3. Convert easily between different Javascript organizations (simple JSON, RDF/JSON).
4. Calculate minimal patches to send back to the server for updates.
5. Calculate and display version history differences.
6. Provide methods for loading SPA implementations in external HTML files without triggering a browser HTML document load.
7. Provide simple methods for issuing GET, PATCH, POST and DELETE requests with RDF payload.

All of this is provided by Javascript libraries in [lda-clientlib](https://github.com/davetropeano/lda-clientlib).

### is HTML a programming language or a declarative markup language?

People have debated for a long time whether HTML is a programming language or a declarative markup language (You can Google 'is HTML a programming language'). In our opinion it is quite obviously both. In the very early days of the web, HTML was used exclusively as a text markup language for exposing documents. As the web evolved to allow commerce and other uses, programming constructs were added to HTML. You can easily recognize the programming constructs, because their use requires the understanding of an underlying processing model. Body, div, span, paragraph and anchor tags (but not all their attributes) can be explained without reference to any sort of processing model. In contrast, tags like form, and attributes like onclick can only be explained with reference to an underlying processing model. In the representations of our resources, we only make use of the data markup parts of HTML, and we never put information in our HTML representation that is not also present in the other representation formats like JSON, Turtle and so on. By contrast, we have HTML resorces that are part of the implementation of the SPA that make extensive use of the programming constructs of HTML, but contain no resource data. In other words, we use HTML as both a document markup language and a UI programming language, but never both at the same time. The more conventional - but in our view less satisfactory - approach is to mix these together.
