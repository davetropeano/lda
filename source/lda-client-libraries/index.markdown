---
layout: page
title: "LDA Client Libraries"
date: 2014-03-28 15:09
comments: true
sharing: true
footer: true
---
### ROCA and SPAs
A popular way of writing web applications today is to write what is called a "Single-Page Application" or SPA. The way an SPA works is that a GET on an initial resource on the server will load an HTML program that presents the UI of the resource. This UI program will subsequently load other resources from the server asking for a data-oriented format - usually JSON - so no new HTML will be loaded. As a result, the UI is often more responsive, since there is no need to load new HTML for each resource. SPAs are also often easier to write, because they provide an easy way of preserving the state of the user interaction across resources. The use of web technologies to develop mobile applications has given a fillip to SPA designs, since mobile apps are SPAs almost by definition.

There is a common perception that SPAs necessarily violate the principles of the resource-oriented architecture that underlies the classic view of the world-wide web - for example, see [ROCA](http://roca-style.org/). We are big fans of the ROCA principles (which are a sort of clarification of the core REST architecture of the web) and agree that it is true that most SPAs have the unfortunate characteristic of violating them in various ways, but we do not think it is necessarily so - you just have to learn to write SPAs so that they conform to the rules. The LDA client libraries help implement SPAs that conform. Here is how we think a ROCA-compliant SPA should work, along with a description of how the LDA client libraries facilitate this. First the ROCA rules themselves.

  1. Our definition of a SPA is that is does a single HTML document load (this concept is defined in the specifications that govern how browsers work) but displays multiple web resources to the user. "Single Document Application" would have been a more accurate term for SPA, but SPA has become an industry term..
  2. Each resource that is displayed by the SPA is a true resource on the server that has an HTML representation and one or more data-oriented representations (usually JSON) and can be accessed by any tool (e.g. a browser, CURL, a web bot, a search engine crawler etc.).
  3. The SPA will never display a URL in the address bar that is not the URL of a true server resource as described above.
  4. Whenever the focus of the user interface moves to a particular resource, the SPA will change the URL in the web browser address bar to show the URL of that resource. Each time the address bar changes, the end user's perception is that there has been a page change, even though there has not been a new HTML document load and we are inside the same SPA. The information visible in the user interface may include information from 'secondary' resources that are not the 'primary' resource whose URL is in the address bar.
  5. Whenever the user uses the reload button of the browser, or copies the URL of the resource from the address bar into a different browser window, the same SPA must load (as part of the HTML document load) and the SPA must position the user interface on the resource whose URL was given. This means that the SPA must not have a preconceived notion of what the 'starting' URL is.
  6. The browser back, forward and history buttons must work exactly as the user would expect, given the sequence of URLs that have been displayed in the address bar.

As mentioned above, many people assume that it is impossible to implement an SPA with these characteristics, but in fact it is quite simple once you see how. The key design principle that makes it possible is the following:

`
In the HTML representation of each resource, the data of the resource and the implementation of the SPA must both be present, but they must be kept separate
`

The reason the HTML representation must include the data of the resource as well as the implementation of the SPA (or a reference to it) is that the HTML representation of the resource must be readable by clients other than the browser. The most important of these from a commercial perspective is usually the search engine crawlers, but there are many others.  A common mistake when implementing SPAs is to have an HTML representation of the resource that only includes the SPA implementation, and assume that the SPA will then turn around and load the appropriate data - this approach breaks all clients except the browser.

The reason you must keep the data of the resource separate from SPA implementation is that the same SPA code must be able to display any of the resources it is responsible for as the initial resource displayed to the user (for reload, and typing URLs into browsers). A common mistake in implementing SPAs is to assume that there is a privileged 'initial' resource whose HTML representation will load the SPA and to then intermingle the SPA implementation with the data of this resource.

### is HTML a programming language or a declarative markup language?

People have debated for a long time whether HTML is a programming language or a declarative markup language (You can Google 'is HTML a programming language'). In our opinion it is quite obviously both. In the very early days of the web, HTML was used exclusively as a text markup language for exposing documents. As the web evolved to allow commerce and other uses, programming constructs were added to HTML. You can easily recognize the programming constructs, because their use requires the understanding of an underlying processing model. Body, div, span, paragraph and anchor tags (but not all their attributes) can be explained without reference to any sort of processing model. In contrast, tags like form, and attributes like onclick can only be explained with reference to an underlying processing model. In the representations of our resources, we only make use of the data markup parts of HTML, and we never put information in our HTML representation that is not also present in the other representation formats like JSON, Turtle and so on. By contrast, we have HTML resorces that are part of the implementation of the SPA that make extensive use of the programming constructs of HTML, but contain no resource data. In other words, we use HTML as both a document markup language and a UI programming language, but never both at the same time. The more conventional - but in our view less satisfactory - approach is to mix these together.

### Example HTML representation

If the description above seems a bit philosophical, an example will probably make it clear. Here is the HTML representation of one of the resources from one of our sample applications:

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

The first thing you will notice is that there is no visible 'UI programming' in this representation - all you see are div, span and a elements that contain the data properties of the resource (a 'Category' resource in this case). The format we are using here is RDFa, which we like a lot, but you could use other things, like the conventions at [schema.org](https://schema.org/) (although our current libraries won't help you read those in your SPA). This representation is attractive for its simplicity, but in practice it is probably a bit too simple. A search engine crawler could get some useful information from this representation, but probably not as much as you would like if you are thinking about search engine optimization (SEO). A more evolved representation (our server framework - described later - has a flag you can set to generate more complex HTML) would have more information for SEO, but it still would not include the SPA implementation.

As you can see, the SPA implementation is included by reference using the following tag:

```
<script src="/setupshop/application.js" type="text/javascript"></script>
```

The entire implementation of the SPA is in /setupshop/application.js, which happens to be on the same server as the resource itself in this case, but could actually be anywhere on the web.

You might imagine from this that the implementation of our SPA is entirely in Javascript code. We implement it this way, but that has at least two disadvantages:

  1. Developers are used to implementing UI in HTML files
  2. UI implemented in HTML files is easier for 3rd-parties to inspect and learn from

Because of this, our Javascript really just does a bit of housekeeping (explained below) and then loads another HTML resource which contains the real SPA implementation without triggering another HTML document load. That HTML resource is not specific to any particular resource on our system, can be anywhere on the web, and can load further javascript. (The implementation HTML is, of course, a web resource itself but it is not a resource whose URL will ever be visible to an end-user.) You can inspect the SPA implementation HTML using the browser debug tools.

Once you have understood how this separation enables ROCA-compliant SPAs, you can probably figure out how to implement the rest yourself, but our client libraries contain some functions to make this easier.

When an SPA causes the UI to navigate to the initial resource (the one the user loaded) or navigates between resources, it needs to do it with some care to make sure the ROCA rules will be satisfied. There are really only 3 situations in which an SPA navigates to a resource:

  1. A user clicks on an anchor tag that was created by the SPA in the first place.
  2. A user uses one of the browser history navigation capabilities, like the forward and back buttons.
  3. Javascript that is part of the SPA implementation decides to move to a new resource. This includes the case when the newly-loaded SPA is deciding what the initial resource to display is.

The client libraries include a standard 'Dispatcher' class that applications can use to unify these 3 cases and provide standard handling of history.

Here is a list of some of the functions of the client libraries:

1. Provide a dispatcher function that helps SPAs integrate with the browser history and navigation mechanisms in ways that support the ROCA principles.
2. Read HTML representations that contain RDFa (potentially in the future schema.org) information and convert it into Javascript objects that are useful for programming.
3. Convert easily between different Javascript organizations (simple JSON, RDF/JSON).
4. Calculate minimal patches to send back to the server for updates.
5. Calculate and display version history differences.
6. Provide methods for loading SPA implementations in external HTML files without triggering a browser HTML document load.
7. Provide simple methods for issuing GET, PATCH, POST and DELETE requests with RDF payload.

All of this is provided by Javascript libraries in [lda-clientlib](https://github.com/davetropeano/lda-clientlib).
