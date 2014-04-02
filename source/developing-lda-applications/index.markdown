---
layout: page
title: "Developing LDA Applications"
date: 2014-04-02 13:45
comments: true
sharing: true
footer: true
---
As with most technologies, the easiest way to get started is to look at an example. To help you get an idea of how LDA applications are implemented, we'll start with a very simple 'Todo List' application from the [lda-examples](https://github.com/ld4apps/lda-examples) repository. You should be able to understand the framework just by reading, but you might also like to install the software yourself and follow along in a more hands-on fashion. If so, refer to [Getting Started](http://ld4apps.github.io/getting-started/index.html) before proceeding.

Every LDA-based application requires a minimum of two files:

  1. logic_tier.py
  2. application.js

### logic_tier.py

This is a python file that implements the server application, which takes the form of a Python class. This class can get all the standard REST/RDF behavior by subclassing a class provided in the framework. The simplest file to get started looks like this:

```python
import example_logic_tier as base
class Domain_Logic(base.Domain_Logic):
    pass
```

Because of the code it inherits, this trivial implementation already supports the full HTTP/REST protocol. You will override these behaviors to implement business logic specific to your application - validations, augmentations, side-effects, and so on.

The inherited code is found in two library modules called logiclibrary and mongodbstorage. When these are more mature, we will no doubt supply them as Python 'eggs'. For now they are available in the [lda-serverlib](https://github.com/ld4apps/lda-serverlib) repository which you need to download from github.

If you look at the 'Todo List' application, you'll see that its logic_tier.py implementation class (located in lda-examples/todo/src/logic_tier.py), is exactly the simple implementation shown above. It adds no custom server implementation code of its own.

### application.js

This is a Javascript file that implements your client application, which is usually a mobile or web user interface. This file, and any others it references, can be anywhere on the web - they do not have to be on your business logic server - we have run them from Amazon S3, for example. application.js can do anything it wants, but the following example file will take advantage of the libraries we have written to support REST and RDF, and still let your application do pretty much anything it wants.

```javascript
var onload_function = function() {
    var head  = document.getElementsByTagName('head')[0]
    var util_script = document.createElement('script')
    util_script.type= 'text/javascript'
    util_script.src = '/clientlib/utils.js'
    util_script.onload = function() {
        ld_util.onload({}, 'exampleserver/application.html', null)
    }
    head.appendChild(util_script)
}
window.addEventListener('DOMContentLoaded', onload_function, false)
```
What this code does basically is load the LDA utils.js client libarary (see [lda-clientlib](https://github.com/ld4apps/lda-clientlib)) first, and then load application.html which is a file you will write. If you choose to use the LDA client libraries (which we recommend) your application.html must contain an html body, but no html, header or body tags. Other than that, you can put whatever you like in application.html - it can load and execute whatever javascript libraries it likes, and include whatever html it likes. A very reasonable thing to do is to use this 'standard' implementation of application.js shown above unmodified and consider application.html as being the real 'root' of your UI application. This is, after all, the normal way you build a web or mobile application - it all starts with your root html file. We will explain more later on this.

If you look at the 'Todo List' application's version of application.js, you'll notice that it is slightly more complicated than the simplest 'standard' one above. It looks like this:

```javascript
BP = 'http://open-services.net/ns/basicProfile#'
TD = 'http://example.org/todo#'

var onload_function = function() {
    var type_to_theme_map = {}
    type_to_theme_map[BP+'Container'] = '/todo/list.html'
    type_to_theme_map[TD+'Item'] = '/todo/item.html'

    var head  = document.getElementsByTagName('head')[0]
    var util_script = document.createElement('script')
    util_script.type= 'text/javascript'
    util_script.src = '/clientlib/utils.js'
    
    util_script.onload = function() {
        ld_util.onload({}, type_to_theme_map, null)
    }
    head.appendChild(util_script)
}

window.addEventListener('DOMContentLoaded', onload_function, false)
```

As you can see, the only difference is that instead of loading the single applications.html file, it consturcts and passes a simple type-to-file map, instucting the framework to load one of several (in this case 2) html files, depending on the (RDF) type of the resource being loaded. If the resource is a (todo) item, we load item.html to display the individual item. If the resource is a container, we load list.html to display the todo list iteself. This demonstrates the fundamental pattern that the LDA framework uses to implement [Single Page Applictions (SPAs)](http://ld4apps.github.io/lda-client-libraries/index.html). We'll look at the 'Todo List' client implementation in more detail below.

The 'Todo List' sample includes a couple of other things any LDA application typically needs:

  1. A setup.py file - You can execute this server file with Python to download the python dependencies of the framework. [We do our best to minimize dependencies, but we do have a few. Currently they are: requests, webob, pycrypto, pymongo, isodate, python-dateutil, rdflib, and werkzeug. requests and webob are popular python libraries that implement functions for sending http requests and reading data from http inputs. pycrypto is a cryptography library that is only required if you are using the authentication feature. pymongo is the python client library for MongoDB. isodate and python-dateutil provide methods to help with Date formatting and parsing. rdflib allows us to support a broad range of RDF data formats without any work on the application developer's part. werkzeug is only used in the single-application development environment, and then only to serve static files.]

  2. A shell/bat command to start the application in a python web server. This is only used for development configurations - in production this job would fall to standard web servers and application servers like Apache, Nginx, uWSGI, GUnicorn etc.

## Hands-on

We will now go through a simple demo using a browser to add and display todo items.

The first thing to do is run the todo application server in a command/shell window:

![](images/run.png)

At this point, you can go to a browser and enter the address "localhost:3007/items". In the browser you will see something like this:

![](images/list1.png)

You can add todo entries to the list by entering them in the text field and pressing the 'Add Todo Item' button:

![](images/list2.png)

Notice that each entry added to the list is also a clickable link. If you click on the first entry in the list you will see a (less than user-freindly) representation of that entry:

![](images/item1.png)

So, how is this application working? Let's start by looking at the html file that is loaded when we're looking at the todo list itself (that's lda-examples/todo/wsgi/static/todo/list.html, if you're looking at the project source):

```html
<input type="text" id="item" name="item" placeholder="What do you need to do?" style="width: 200px;">
<input type="button" value="Add Todo Item" onClick="addItem();">

<hr>

<div id="todoItems"></div>
<hr>

<script>
function appendItem(item, location) {
    document.getElementById("todoItems").innerHTML += "<li><a href=\"" + location + "\">" + item + "</a></li>"
}

function displayItems() {
    var items = APPLICATION_ENVIRON.initial_simple_jso.bp_members
    for (var i in items) {
        appendItem(items[i].dc_title, items[i]._subject);
    }
}

function addItem() {
    var title = document.getElementById("item").value.trim();
    if (title == '') return;

    var item = {
        "_subject": "",
        "dc_title": title,
        "rdf_type": "http://example.org/todo#Item"
    };

    var response = ld_util.send_create("", item);
    if (response.status == 201) {
        var location = response.getResponseHeader("location");
        appendItem(item.dc_title, location);
        document.getElementById("item").value = "";
    }
    else
        console.log(response);
}

// allow enter key to be pressed and act as submit
document.getElementById('item').onkeydown = function(e) {
    e = e || window.event;
    if (e.keyCode == 13) {
        addItem();
    }
};


displayItems();
</script>
```

For anyone familiar with html/javascript programming, there should be nothing surprising here. This is very simple UI, intentionally written to use no fancy UI frameworks/libraries, other than the LDA clientlib. We have other samples that use UI frameworks to provide much nicer displays, but here we kept the example as simple as absolutely possible.

However, if you look at the source of the page, you will see this:

![](images/image04.png)

This will be surprising to many HTML programmers. The HTML contains an RDFa representation of the data resource at "localhost:3007/tt". This HTML does not attempt to render the information in any interesting way and even if it did, we are not using it anyway - we load application.html over top of it instead. [On our to-do list is to allow server developers to embellish the RDFa representation for search-engine optimization, but not to implement UI presentation.] What the user actually sees is the content provided by application.html, which was loaded by application.js.

[If you turn off javascript in the browser, you will actually see the RDFa rendered. There is also an environment variable you can set on the server that will generate more elaborate RDFa that actually does render itself in a more readable way if Javascript is off. This will not give you a reasonable UI for your application, but it can be useful/amusing for debugging or pedagogical purposes.]

Why do we do things this way? This approach allows a very clean separation of the server, which concerns itself only with business logic and data storage, and the user interface, which is implemented in HTML and javascript and which does not even have to reside on the same server as the business logic (we have run with the UI files on Amazon S3, for example).

localhost:3007/x \- where x is any simple path segment - is the name of a container to which you can POST to create new resources, and which you can GET to see what you already have. [Of course, you can override all this default behavior if you want by writing Python code.] If you POST to localhost:3007/x, it will create a resource whose URL is localhost:3007/x/n.m, where n is the numerical id of the server copy that handles the request (a small monotonically-increasing number) and m is the numerical id of the resource (another monotonically-increasing number). Clients do not need to know this information - for them URLs should be opaque and anyway we may choose to change these rules on the server - but you as a server developer using the framework may be interested.

['items' is just the value of x we will use for the todo example - you can actually enter "localhost:3007/x" where x is anything you fancy. Normally you would be running behind a reverse proxy that is configured to only forward the values of x that you have chosen for your subsystems, but here we are running wide- open in development so you can enter anything.]



### Customizing the UI

We can easily enhance  application.html to show a (slightly) more interesting view of the resource as follows:

![](images/image01.png)

Hitting the refresh button on the browser will produce this:

![](images/image21.png)

Don't worry about the detail of the information shown here - we'll come back to it in a longer discussion of containers. Also, be aware this is not a JSON format - it's a JSON-like display rendering to help you understand what data is there.

When application.js ran it loaded our utility library, and then called an onload function in that library. The RDFa content in the HTML representation of the resource holds important information, but not in a format that is very friendly to Javascript programmers, so the utility onload function converts it to more usable Javascript objects in memory - similar to the 'simple JSON' ones described in the RDF lessons above - which it then sets as a property called initial_simple_jso in a global variable called APPLICATION_ENVIRON. It then erases the RDFa from the HTML document body and replaces it with the contents of application.html.  In this example, the script in application.html finds these Javascript objects, converts them to a string, and then replaces the HTML document body once again with the result.

### Exercising the server API

We can now use the browser console to create a new resource in this container, as shown in this screen-shot:

![](images/image22.png)

The command we used was

```javascript
request = ld_util.send_create("", {"_subject":"", "prop1":"val1"})
```

ld_util.send_create is a function in the utility libraries we loaded. All it really does is set a couple of standard headers and send an HTTP POST message. The URL we send the post to is the first argument - "" \- the null relative address, which is equivalent to "localhost:3007/tt", since that is the url the browser is on. The object we send in the POST body also has its _subject set to the null relative address, but this address will be interpreted as being relative to the to-be-created resource, not the container we're POSTing to.

You can see from the request that the server responded with '201 Created' and the response body is the newly-created resource. The server also returned a 'Location' response header with the URL of the newly-created resource. If we click on this URL in the console window, we will see this:

![](images/image02.png)

[Note that this resource is being displayed by the same application (/tutorial/application.js) that displayed the collection.] If you look at the source for /tt/13.2, it looks like this:

![](images/image05.png)

If you refresh the container (it is still in the previous tab), it now looks like this:

![](images/image00.png)

Even without worrying about the detail - explained later - you can see there is a new member in the container.

In the previous example, we POSTed to a container whose URL is '/tt'. This container is useful for bootstrapping, because it pre-exists without us doing anything, but it is better for applications to create their containers explicitly. Suppose I have an application that needs one container for 'friends' and another for 'family'. We could use '/friends' and '/family' for this purpose, but doing so has at least two disadvantages:

  1. You will have to update the routing tables of the reverse proxy each time I add another container
  2. The contents of '/friends' and '/family' will be stored in different database collections, so I will not be able to do any queries that span both of them

Fortunately the alternative is very simple. I can execute these two statements:

```javascript
req = ld_util.send_create('', {
    _subject : "",
    rdf_type : new rdf_util.URI("[http://open- services.net/ns/basicProfile#Container](http://www.google.com/url?q=http%3A%2F %2Fopenservices.net%2Fns%2FbasicProfile%23Container&sa=D&sntz=1&usg=AFQjCNGpp 0PHvTcHtI4l3ho9BiDoHhvDrA)"),
    bp_membershipPredicate: 'friend',
    bp_membershipSubject: new rdf_util.URI('[http://localhost:3007/](http://www.g oogle.com/url?q=http%3A%2F%2Flocalhost%3A3007%2F&sa=D&sntz=1&usg=AFQjCNEKf- xaxbl3WGyePWerq7u-Fjuq4A)')}
)

req = ld_util.send_create('', {
    _subject: "",
    rdf_type: new rdf_util.URI("[http://open- services.net/ns/basicProfile#Container](http://www.google.com/url?q=http%3A%2F %2Fopen-services.net%2Fns%2FbasicProfile%23Container&sa=D&sntz=1&usg=AFQjCNGpp 0PHvTcHtI4l3ho9BiDoHhvDrA)"),
    bp_membershipPredicate: 'familyMember',
    bp_membershipSubject: new rdf_util.URI('[http://localhost:3007/](http://www.g oogle.com/url?q=http%3A%2F%2Flocalhost%3A3007%2F&sa=D&sntz=1&usg=AFQjCNEKf- xaxbl3WGyePWerq7u-Fjuq4A)')}
)
```

These two statements will create new resources with URLs something like '/tt/1.3' and '/tt/1.4' respectively. Each of these is a container, just like '/tt'.

I can now execute these statements:

req = ld_util.send_create('/tt/1.3', {_subject : '', name : 'Jane'})

req = ld_util.send_create('/tt/1.3', {_subject : '', name : 'Alice'})

req = ld_util.send_create('/tt/1.4', {_subject : '', name : 'Steve'})

req = ld_util.send_create('/tt/1.4', {_subject : '', name : 'Dennis'})

This will create resources '/tt/1.5', '/tt/1.6', '/tt/1.7', and '/tt/1.8'. If you now do a GET on '/tt/1.3' and '/tt/1.4' you will see their contents as expected.

The exact meaning of the predicates bp_membershipPredicate and bp_membershipSubject will become clear in the next section.

