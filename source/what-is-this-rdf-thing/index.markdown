---
layout: page
title: "What is this RDF Thing?"
date: 2014-03-28 15:46
comments: true
sharing: true
footer: true
---
Before you can use the server-implementation part of the LDA framework, you will need some understanding of the data structures in the messages that will go in and out of an application built on it. These structures are based on RDF. We will assume in this section that you are not already an expert in RDF.

If you are like most people, when you want to find out about something you don't already know, you Google it. In the case of RDF this may not be a good idea, because you will be led to a lot of confusing information that makes RDF seem much more strange and complex than it really is. This description will try to demystify RDF by describing it from the starting point of someone who already knows JSON and likes its simplicity.

One important thing to understand about RDF is that it is a data model, not a data format, so RDF data can be represented in XML, JSON and other formats. From a programmer's perspective, the interesting question might be how RDF data is represented in programming-language data structures (objects, arrays, literals). Since there is a very direct correspondence between JSON and the data structures of popular programming languages like Python, Ruby and Javascript, understanding a JSON format for RDF data gets you a long way towards answering this question.

### RDF for JSON programmers - lesson 1

Let's take the example of an on-line product review at Amazon.com. Since Amazon URLs are long and complicated and difficult to read (they should work on that), we're going to substitute them as follows:

Simplification | Real Amazon URL
---            | ---
http://az.com/reviewer_1 | http://www.amazon.com/gp/pdp/profile/A3KHHVMTMUX6X8/ref=cm_cr_pr_pdp
http://az.com/reviewer_2 | http://www.amazon.com/gp/pdp/profile/A36NZ8AO7R5BQ0/ref=cm_cr_rdp_pdp
http://az.com/review_1 | http://www.amazon.com/review/RE9YX25OLHSY4/ref=cm_cr_pr_perm?ie=UTF8&ASIN=B003MTTJOY&linkCode=&nodeID=&tag=
http://az.com/review_2 | http://www.amazon.com/review/R1KU1SEX1ZJW74/ref=cm_cr_pr_perm?ie=UTF8&ASIN=B003MTTJOY&linkCode=&nodeID=&tag=
http://az.com/product_1 | http://www.amazon.com/Edimax-EW-7811Un-Wireless-Adapter-Wizard/dp/B003MTTJOY/ref=cm_cr_pr_product_top

Now, what would http://az.com/review_1, for example, look like in JSON? A programmer familiar with JSON would probably suggest something like this:

```json
{
    "found_helpful" : 180,
    "found_helpful_or_not" :192,
    "stars" : 4,
    "title" : "Good little Wifi Adapter",
    "reviewer" : "http://az.com/reviewer_1",
    "reviewOf" : "http://az.com/product_1",
    "verified_purchase" : true,
    "text" : "I purchased this to add wireless connectivity to my Raspberry Pi [...]"
}
```

*We are assuming that our programmer already understands and is following the REST model. A programmer following the rpc-over-http model would probably have provided database primary keys for reviewer and product, and would have expected clients to compose URLs by tacking the database primary key onto some URL string prefix, likely with a '?' in between and maybe an '=' for good luck.*

It is hard to quarrel with the simplicity and intuitiveness of this JSON, and we will try not to spoil it as we convert it to RDF.

If we put aside the notation and look at the underlying data model for the above information, it might look like this:

Property | Value
---      | ---
found_helpful | 180
found_helpful_or_not | 192
stars | 4
title | Good little Wifi Adapter
reviewer | http://az.com/reviewer_1
reviewOf | http://az.com/product_1
verified_purchase | true
text | I purchased this to add wireless connectivity to my Raspberry Pi [...]

It is clear this is a set of property-value pairs, but it is less clear what they are the property-values of. Our JSON programmer would probably say that they are the values for the review whose representation this is. In other words, if you do a GET on the review http://az.com/review_1 then you can assume that the property values returned are the property values of http://az.com/review_1. Although this assumption sounds reasonable, it turns out to be a problem in more complex cases (see the next example) and implicit assumptions often turn into problems later, even in simple cases, so we are going to remove the assumption by making the information explicit. We do this by adding a new JSON property, as follows.

```json
{
    "_subject": "http://az.com/review_1",
    "found_helpful" : 180,
    "found_helpful_or_not" :192,
    "stars" : 4,
    "title" : "Good little Wifi Adapter",
    "reviewer" : "http://az.com/reviewer_1",
    "reviewOf" : "http://az.com/product_1",
    "verified_purchase" : true,
    "text" : "I purchased this to add wireless connectivity to my Raspberry Pi [...]"
}
```

Congratulations, you just (re-)invented RDF! Really, that is all there is to it - the rest is detail. People knowledgeable of RDF will quibble with some aspects of this representation, but we claim that we have already converted our simple JSON to an RDF data model. What we did looks trivial, but it's actually quite profound. You have to realize that _subject is really not another property of the review. The data model we derive from the new JSON is not the following table as you might expect:

Property | Value
---      | ---
_subject | http://az.com/review_1
found_helpful | 180
found_helpful_or_not | 192
stars | 4
title | Good little Wifi Adapter
reviewer | http://az.com/reviewer_1
reviewOf | http://az.com/product_1
verified_purchase | true
text | I purchased this to add wireless connectivity to my Raspberry Pi [...]

Instead, the data model is this:

Subject | Property | Value
---     | ---      | ---
http://az.com/review_1 | found_helpful | 180
"" | found_helpful_or_not | 192
"" | stars | 4
"" | title | Good little Wifi Adapter
"" | reviewer | http://az.com/reviewer_1
"" | reviewOf | http://az.com/product_1
"" | verified_purchase | true
"" | text | I purchased this to add wireless connectivity to my Raspberry Pi [...]

The essential idea is that _subject is not specifying a new property of the review, instead it's defining which review we are talking about.

The key ideas that make RDF different from ordinary Javascript objects are these.

  1. Simple Javascript objects contain property-value pairs, while RDF adds the information about whose property-value pairs they are (the 'subject', in RDF terminology)
  2. The subject of the property-value pairs is identified by a URI

We will add a caution here. In its essence, RDF really is as simple as described above, but the fact that it is simple does not make it easy. It takes some time to really understand the implications of this simple model, and to unlearn assumptions one is typically carrying over from an object-oriented way of thinking that do not apply in RDF.

If our warning came too late and you have already done some Googling on RDF, let's relate this to what you might have seen. The three-column table above is a rendering of the standard RDF "graph of triples" - each row describes one triple. RDF calls sets of triples like these 'graphs', and the standard tutorial material usually emphasizes how you can match URL values in the left column with URL values in the right column to form a graph (potentially multiple disconnected graphs) from the table. In our experience it's often more useful to think of a set of RDF triples as a simple table than as a graph. Also, there is a W3C recommendation called JSON-LD that specifies an 'approved' version of what we just did with "\_subject". Unfortunately, JSON-LD says you should use "@id" instead of "\_subject", but since that choice is awkward to deal with in some programming languages (e.g. Javascript), and incompatible with some popular programming libraries, we don't recommend (or implement) spec compliance on this point. JSON-LD is a large specification with many options - what we just did above is compatible with just one important option in the spec (if you ignore the details).

*Those of you with sharp eyes for detail may have noticed a little irony in the RDF table above. In the first column we used "" to mean ditto to avoid repeating the long URL at the top of the column. However, "" could also be interpreted literally to mean the empty string, which is also a valid URL - it is the null relative URL - which happens to also be a correct URL value in this case, where the representation is the result of a GET on the longer url.*

You may not be convinced yet that you should care about RDF. A reasonable reaction to the above discussion might be "OK, it makes sense, and it's not difficult to do, but really, I was doing fine without this, and I have more pressing things to work on". Let's look at another example to try to convince you.

### RDF for JSON programmers - lesson 2

In the example above, we had a product whose URL is http://az.com/product_1.

As you might expect, at Amazon.com, each review is its own resource with its own URL that you can bookmark. Given a product, we will need to be able to find the reviews for the product, so assume that corresponding to this product there is a resource that represents its collection of reviews, whose URL is this:

```html
http://az.com/product_1/reviews
```

*You would find this URL inside the representation of http://az.com/product_1 and you would not try to guess it by postpending 'review' to the stringified URL of the product.*

If we asked the same JSON programmer that we asked before to give us the JSON for this collection of resources, she might suggest this:

```json
[
    "http://az.com/review_1",
    "http://az.com/review_2",
    ...
]
```

If the representation of a collection only contains the URLs of the collection's members, it's not very convenient for a client, because most use-cases will require the client to then fetch each member of the collection individually via HTTP GET. Even without input from us, our JSON programmer would probably be pushed by her client colleagues to enhance the representation to be something more like this:

```json
[
    {
    "_subject": "http://az.com/review_1",
    "found_helpful" : 180,
    "found_helpful_or_not" :192,
    "stars" : 4,
    "title" : "Good little Wifi Adapter",
    "reviewer" : "http://az.com/reviewer_1",
    "reviewOf" : "http://az.com/product_1",
    "verified_purchase" : true,
    "text" : "I purchased this to add wireless connectivity to my Raspberry Pi [...]"
    },

    {
    "_subject": "http://az.com/review_2",
    "found_helpful" : 72,
    "found_helpful_or_not" :77,
    "stars" : 5,
    "title" : "great little product for price!",
    "reviewer" : "http://az.com/reviewer_2",
    "reviewOf" : "http://az.com/product_1",
    "verified_purchase" : true,
    "text" : "I was amazed at how tiny it is! [...]"
    },

    ...
]
```

Notice that our programmer had to invent "_subject" (or some synonym for that concept) for this case - even without having seen our first RDF lesson - because the outer context can no longer be depended on to know what resources the information pertains to. This means that the programmer was already using a homemade form of RDF, but had not formalized it and was not doing it consistently. What we have found is that there are many cases like this where a common design issue in JSON has a very natural solution when you view things from an RDF perspective. Taking advantage of the work that has been done by a community of smart people to formalize the RDF model helps architects with overall design integrity, at the cost of having to read and decode the RDF literature. Alternatively, you can build on the LDA framework and have a lot of it done for you <g>.

Even though each entry already has a '_subject', we are still relying on context to convey another piece of implicit information in this example - there is nothing in the data that tells us that these reviews are the members of the collection. Here is the table of triples that can be derived from the data as it currently appears:

Subject | Property | Value
---     | ---      | ---
http://az.com/review_1 | found_helpful | 180
"" | found_helpful_or_not | 192
"" | stars | 4
"" | title | Good little Wifi Adapter
"" | reviewer | http://az.com/reviewer_1
"" | reviewOf | http://az.com/product_1
"" | verified_purchase | true
"" | text | I purchased this to add wireless connectivity to my Raspberry Pi [...]
http://az.com/review_2 | found_helpful | 72
"" | found_helpful_or_not | 77
"" | stars | 5
"" | title | great little product for price!
"" | reviewer | http://az.com/reviewer_1
"" | reviewOf | http://az.com/product_1
"" | verified_purchase | true
"" | text | I was amazed at how tiny it is! [...]

You can see that we are simply assuming that if these reviews are mentioned in the collection's 
representation, it must mean that they are members of the collection. Since we don't like these sort of implicit assumptions, we will make it explicit. We actually have two different ways of doing this - we'll start with the more obvious one.

```json
{
    "_subject" : "http://az.com/product_1/reviews",
    "member" : [
        {
        "_subject": "http://az.com/review_1",
        "found_helpful" : 180,
        "found_helpful_or_not" :192,
        "stars" : 4,
        "title" : "Good little Wifi Adapter",
        "reviewer" : "http://az.com/reviewer_1",
        "reviewOf" : "http://az.com/product_1",
        "verified_purchase" : true,
        "text" : "I purchased this to add wireless connectivity to my Raspberry Pi [...]"
        },

        {
        "_subject": "http://az.com/review_2",
        "found_helpful" : 72,
        "found_helpful_or_not" :77,
        "stars" : 5,
        "title" : "great little product for price!",
        "reviewer" : "http://az.com/reviewer_2",
        "reviewOf" : "http://az.com/product_1",
        "verified_purchase" : true,
        "text" : "I was amazed at how tiny it is! [...]"
        },

        ...
    ]
}
```

Although this added a whole new level of nesting to the JSON, in reality it just added two new triples to our table:

Subject | Property | Value
---     | ----     | ---
http://az.com/product_1/reviews | member | http://az.com/review_1
"" | member | http://az.com/review_2
... | ... | ...

Now we have triples that declare explicitly which resources are the members rather than relying on assumptions.

*Note that the _subject JSON property of the reviews is playing double-duty here - it is defining the subject of the property-values within the nested JSON objects for the reviews, and it is defining the values of the 'member' property for the outer JSON object that represents the collection.*

In this example, we forced the programmer to complicate the representation of the collection with an extra level of nesting. However, it's quite likely that she would have needed to do this anyway. Suppose for example, that we decide to record other information for the collection, like the time of the last update, or the number of entries - there are many plausible property values for a collection. The simplest way of adding these properties is to organize the data the way we have shown.

Hopefully we have convinced you that our conversion to the RDF data model has preserved the simplicity and intuitiveness of the JSON a programmer originally came up with and that the changes we imposed were pretty desirable ones anyway.

*In case you are wondering about the other technique for specifying the members, it amounts to providing some properties on the collection itself that together specify a rule that says 'to find the members, look for all x such that a triple (x, "reviewOf", "http://az.com/product_1") is in the representation'. You can see in the data above that this gives the same result as the member triples, and you will see later why that is an interesting way to think about collection membership.*

### RDF is a different perspective

Here are a couple of examples that will show you that even though RDF is very simple, it can challenge your object-oriented pre-conceptions. Consider this JSON

```json
[
    {
    "_subject": "http://martin-nally.name",
    "givenName" : "Martin"
    },
    {
    "_subject": "http://martin-nally.name",
    "familyName" : "Nally"
    }
]
```

The object-oriented programmer in us sees two objects in an array. However, RDF sees only information about a single resource - http://martin-nally.name. The fact that the information in the resource representation was grouped into two different objects has no meaning for RDF - it all boils down to this table:

Subject | Property | Value
---     | ---      | ---
http://martin-nally.name | givenName | "Martin"
"" | familyName | "Nally

All those little objects don't mean anything - they are just containers for sets of rows for the table.

Here is another example to challenge your object-oriented assumptions. Up above, we looked at the representation of the resource http://az.com/review_1. It looked like this:

```json
{
    "_subject": "http://az.com/review_1",
    "found_helpful" : 180,
    "found_helpful_or_not" :192,
    "stars" : 4,
    "title" : "Good little Wifi Adapter",
    "reviewer" : "http://az.com/reviewer_1",
    "reviewOf" : "http://az.com/product_1",
    "verified_purchase" : true,
    "text" : "I purchased this to add wireless connectivity to my Raspberry Pi [...]"
}
```

This information corresponds to the following RDF table:

Subject | Property | Value
---     | ---      | ---
http://az.com/review_1 | found_helpful | 180
"" | found_helpful_or_not | 192
"" | stars | 4
"" | title | Good little Wifi Adapter
"" | reviewer | http://az.com/reviewer_1
"" | reviewOf | http://az.com/product_1
"" | verified_purchase | true
"" | text | I purchased this to add wireless connectivity to my Raspberry Pi [...]

In RDF, it would be simple and easy to change this line:

Subject | Property | Value
---     | ---      | ---
"" | reviewOf | http://az.com/product_1

to this:

Subject | Property | Value
---     | ---      | ---
http://az.com/product_1 | reviewedIn | http://az.com/review_1

All we did was reverse the direction of the triple - instead of saying "review_1 is a review of product_1", we reversed it to say "product_1 is reviewed in review_1". This information is still held in the representation of the review, not the product, and the information is entirely equivalent - all we did was change the way we stated it.

Although this change was trivial and inconsequential at the RDF level, it is now more complicated to put this information back into a JSON format - try it. *Hint - the structure of each review will become more complex - you will need two JSON objects instead of one to hold the information, but - surprisingly - the structure of the collection http://az.com/product_1/reviews becomes simpler - we no longer have to invent membership triples.*

RDF also allows us to correct a conceptual problem with the data in the original example. The properties 'found_helpful' and 'found_helpful_or_not' are clearly properties of the review - they are trying to indicate how good the review is. However 'stars' is not a property of the review at all - it's trying to say how good the product is, not how good the review is. As humans who speak English, we can use common sense to figure this out, but a computer (other than IBM's Watson, perhaps) can't figure it out, and if the example had been done in a language I didn't know, I couldn't figure it out either. RDF gives us an easy way to correct this, by changing the table for the review to this:

Subject | Property | Value
---     | ----     | ---
http://az.com/review_1 | found_helpful | 180
"" | found_helpful_or_not | 192
http://az.com/product_1 | stars | 4
http://az.com/review_1 | title | Good little Wifi Adapter
"" | reviewer | http://az.com/reviewer_1
"" | reviewOf | http://az.com/product_1
"" | verified_purchase | true
"" | text | I purchased this to add wireless connectivity to my Raspberry Pi [...]

This would convert back to JSON like this:

```json
{
    "_subject": "http://az.com/review_1",
    "found_helpful" : 180,
    "found_helpful_or_not" :192,
    "title" : "Good little Wifi Adapter",
    "reviewer" : "http://az.com/reviewer_1",
    "reviewOf" : {
        "_subject": "http://az.com/product_1",
        "stars" : 4,
    },
    "verified_purchase" : true,
    "text" : "I purchased this to add wireless connectivity to my Raspberry Pi [...]"
}
```

It's unlikely we would have thought of doing this if we had just thought about it from a JSON point of view, but when we looked at it from an RDF point of view, it was pretty obvious what the right fix was.

### Another JSON format for RDF

When we introduced the '_subject' JSON property above, we emphasized that it is not really a property in the underlying data model. There is an alternative approach to organizing the JSON that makes this observation even clearer, and which provides an alternative JSON structure for RDF that is superior for some use-cases, but not all. We'll call this alternative organization RDF/JSON after the [W3C note](https://dvcs.w3.org/hg/rdf/raw-file/default/rdf-json/index.html) that specifies a version of the idea - we support an extended version of that spec. As a reminder, here is our original starting JSON.

```json
{
    "found_helpful" : 180,
    "found_helpful_or_not" :192,
    "stars" : 4,
    "title" : "Good little Wifi Adapter",
    "reviewer" : "http://az.com/reviewer_1",
    "reviewOf" : "http://az.com/product_1",
    "verified_purchase" : true,
    "text" : "I purchased this to add wireless connectivity to my Raspberry Pi [...]"
}
```

With [our slightly more liberal version of] RDF/JSON , instead of introducing '_subject', you do this:

```json
{
    "http://az.com/review_1": {
        "found_helpful" : 180,
        "found_helpful_or_not" :192,
        "stars" : 4,
        "title" : "Good little Wifi Adapter",
        "reviewer" : "http://az.com/reviewer_1",
        "reviewOf" : "http://az.com/product_1",
        "verified_purchase" : true,
        "text" : "I purchased this to add wireless connectivity to my Raspberry Pi [...]"
    }
}
```

The JSON 'names' at the outer level are not property names, they are the URLs of the subjects of the property/value pairs in the inner objects.

With RDF/JSON, you do not nest additional JSON objects the way we saw before with the JSON-LD-inspired format. If you take our container example from above, it would look something like the following in RDF/JSON. [Note this differs in some details from what we do in LDA framework - we'll show you what we really do later.]

```json
{
    "http://az.com/product_1/reviews" : {
        "member" : ["http://az.com/review_1", "http://az.com/review_2"]
    },

    "http://az.com/review_1" : {
        "found_helpful" : 180,
        "found_helpful_or_not" :192,
        "stars" : 4,
        "title" : "Good little Wifi Adapter",
        "reviewer" : "http://az.com/reviewer_1",
        "reviewOf" : "http://az.com/product_1",
        "verified_purchase" : true,
        "text" : "I purchased this to add wireless connectivity to my Raspberry Pi [...]"
    },

    "http://az.com/review_2" : {
        "found_helpful" : 72,
        "found_helpful_or_not" :77,
        "stars" : 5,
        "title" : "great little product for price!",
        "reviewer" : "http://az.com/reviewer_2",
        "reviewOf" : "http://az.com/product_1",
        "verified_purchase" : true,
        "text" : "I was amazed at how tiny it is! [...]"
    }
}
```

From a programmer's perspective, sometimes the [in-memory equivalent of the] RDF/JSON format is more convenient and sometimes the [in-memory equivalent of the] JSON-LD format is more convenient - the client libraries allow you to flip between them without going back to the server. There are a number of technical reasons - too low-level and detailed to discuss here - why RDF/JSON actually works better than JSON-LD as a format to exchange between clients and servers, and this is the format the LDA frameworks and libraries mostly use. This is largely transparent to the client programmer.
