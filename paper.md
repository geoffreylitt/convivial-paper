---
title: "Wildcard: Spreadsheet-Driven Customization of Web Applications"
author: "[Geoffrey Litt](https://www.geoffreylitt.com/) and [Daniel Jackson](http://people.csail.mit.edu/dnj/)"
bibliography: references.bib
link-citations: true
csl: templates/acm-sig-proceedings.csl
reference-section-title: References
abstract: |
  Many Web applications do not meet the particular needs of their users. Browser extensions and user scripts offer a way to customize web applications, but most people do not have the programming skills to implement their own extensions.
  
  We present the idea of _spreadsheet-driven customization_: enabling end users to customize existing applications using a live spreadsheet view of the data inside the application. By manipulating the spreadsheet, users can implement a wide variety of customizations, ranging from sorting lists of search results to displaying related data from other web services, without doing any traditional programming.
  
  We built a prototype system called Wildcard that implements spreadsheet-driven customization as a web browser extension. Through concrete examples, we demonstrate that Wildcard has both a low barrier to entry for beginners and enough flexibility to solve many useful problems. We also show that Wildcard can work with real existing websites, by extracting structured data using web scraping techniques.
---



# Introduction

In 2012, the travel site Airbnb removed the ability to sort listings by price. Users could still filter by price range, but could no longer view the cheapest listings first. Many users complained on online message boards that the change seemed hostile to users. "It's so frustrating!..What is the logic behind not having this function?" said one user on the [Airbnb support forum](https://community.withairbnb.com/t5/Hosting/Sorting-listing-by-price/td-p/559404). Alas, the feature remains missing to this day.

This is a familiar situation in a world of web applications that are frequently updated without user consent. Sometimes there is a browser extension or user script that fixes an issue, and if the user is both motivated and skilled they might even be able to implement their own fix. But for most people, the only recourse is to complain to the developers and pray that someone listens—or more likely, to simply give up. While many have become used to this status quo, we see it as a tremendous waste of the openness of the Web platform. Back in 1977, in _Personal Dynamic Media_ [@kay1977], Alan Kay originally envisioned personal computing as a medium that let a user "mold and channel its power to his own needs," but today software feels more like concrete than clay.

In this paper, we present _spreadsheet-driven customization_, a technique for making software customization more accessible to end users. The core idea is to show the data inside the application in a spreadsheet which maintains a live connection to the original UI. When the user manipulates the spreadsheet, the UI is instantly modified, and vice versa. We built a research prototype called Wildcard that implements spreadsheet-driven customization as a web browser extension, showing a spreadsheet panel in the context of existing sites.

Spreadsheets have proven to be a widely successful computing platform for non-programmers. They provide a low barrier to entry for beginners, while allowing experts to perform complex computations. The 2D grid is simple to grasp, but general enough to represent many types of data. Prior work [@mccutchen2016;@benson2014;@chang2014] has used these benefits to enable end users to easily create web applications that use spreadsheets as a backing data layer.

Spreadsheet-driven customization applies these exact same benefits in a different context: customizing existing software, rather than building new software from scratch. We inherit the low floor and high ceiling of spreadsheets: small tweaks like sorting a list of data in an app can be done with a single click, while more complex customizations, like joining in related data from a web API, are supported by a rich formula system. The tabular data format is versatile, supporting data from a wide range of applications. Spreadsheet-driven customization does not require that the application is actually backed by a spreadsheet—it merely presents a model of the internal state of the application, which can be exposed by the application itself or derived from the user interface by third parties. This means that spreadsheet-driven customization works with existing applications that people already use. It also allows for exposing a common data abstraction across applications, enabling users to have a consistent mechanism for manipulating data from all of their applications.

Prior work [@huynh2006] has shown that the process of extracting structured data from existing user interfaces can be confusing and unfamiliar for end users. In order to make the customization experience as straightforward as possible, we envision a tiered architecture that hides this complexity from end users. Wildcard provides a mechanism for programmers to write _site adapters_, which use web scraping techniques to extract structured data from the DOM and AJAX requests of existing applications. End users only interact with the structured spreadsheet, providing a predictable experience with clear affordances for which customizations are possible.

Wildcard is currently an early prototype, with incomplete features and limited coverage of sites. We plan to continue building site adapters and testing the system with our own use cases, to better understand how well the spreadsheet abstraction maps to real websites and customization needs. Eventually we also plan to release the tool publicly, to determine how end users choose to use spreadsheet-driven customization, what usability challenges emerge, and how feasible it is for programmers to build and maintain site adapters.

# Demo: booking a trip with Wildcard

To get a sense of how it might feel to use Wildcard, let's see an example of someone using it to help with booking a trip on the travel sites Airbnb and Expedia.

The user starts by opening up the Airbnb search listings page to look for a place to stay. The page looks nice and mostly works well, but is missing some key features. As mentioned before, this page doesn't allow the user to sort by price. It also doesn't let them filter by user rating. Using Wildcard, the user can add these small features, while leaving the page's design and the rest of its functionality unchanged.

First, the user opens up the Wildcard panel, which shows a table corresponding to the search results in the page. As they click around in the table, the corresponding row in the page is highlighted so they can see the connection between the views. 

<video width="100%" controls="controls" preload="auto" muted="muted" src="media/table.mp4#t=0.1" muted playsinline controls class>
</video>

Then, the user can use standard spreadsheet column header features to sort the page by price and filter by rating:

<video width="100%" controls="controls" preload="auto" muted="muted" src="media/sort-filter.mp4#t=0.1" muted playsinline controls class>
</video>

Notice how after manipulating the data, the user was able to close the table view and continue using the website with its original visual design. The table view offers a way to change the data backing a page, but does not need to replace the original interface entirely.

Most websites that show lists of data also offer actions that can be taken on a row in the table, like adding an item to a shopping cart. Wildcard has the ability to make these actions available in the data table if the site adapter implements them. The main advantage this provides is the ability to easily perform an action in bulk across multiple rows.

For example, it's tedious on Airbnb to click on listings one by one to add them to a list of favorites. Using Wildcard, we can just select multiple rows and favorite all of them with one click. Similarly, we can also open the detailed pages for many listings in new tabs.

<video width="100%" controls="controls" preload="auto" muted="muted" src="media/favorite-open.mp4#t=0.1" muted playsinline controls class>
</video>

Now the user would like to jot down some notes on the pros and cons of each listing. To do this, they can simply type notes into an additional column next to each listing, and the notes appear inside the listings in the original UI. These annotations are also persisted in the browser for future retrieval. 

<video width="100%" controls="controls" preload="auto" muted="muted" src="media/annotate.mp4#t=0.1" muted playsinline controls class>
</video>

Wildcard also includes a formula language which enables more sophisticated tweaks that fetch external data and perform computations.

When traveling without a car, it's nice to evaluate potential places to stay based on how walkable the surroundings. Using Wildcard formulas, we can integrate Airbnb with Walkscore, an API that rates the walkability of any location on a 1-100 scale. When we call the `WALKSCORE` formula with the latitude and longitude of the listing, it returns the walk score as the cell value. Because the cell's contents are injected into the page, the score also shows up in the page body.

<video width="100%" controls="controls" preload="auto" muted="muted" src="media/walkscore.mp4#t=0.1" muted playsinline controls class>
</video>

It might seem that Wildcard is only useful on websites that display lists of tabular data like search results. But in fact, the table metaphor is flexible enough to represent many types of data. For example, a form can be represented as a single row, with a column for each input.

<video width="100%" controls="controls" preload="auto" muted="muted" src="media/expedia-table.mp4#t=0.1" muted playsinline controls class>
</video>

In previous examples the data extracted from the site was marked as read-only; users cannot change the name or price of an Airbnb listing. In this next case, the cells are marked as writable, so that changes in the table are reflected in the form inputs. This becomes useful when combined with GUI widgets for editing the value of a table cell.

Filling in dates for a flight search typically requires opening up a separate calendar app to find the right dates, and then manually copying them into the form. In Wildcard, we can make this easier by providing a datepicker widget that has privileged access to the user's calendar information.

<video width="100%" controls="controls" preload="auto" muted="muted" src="media/datepicker.mp4#t=0.1" muted playsinline controls class>
</video>

Here we’ve presented just a few possibilities for how to use Wildcard. We think the interactive data table offers a flexible computational model that can support a wide range of other useful modifications, all while remaining familiar and easy to use. 

# System Architecture

Wildcard is written in Typescript. It is currently injected into pages using the [Tampermonkey](https://www.tampermonkey.net/) userscript manager, but in the future we plan to deploy it as a standalone browser extension to make it easier to install.

In order to maximize extensibility, Wildcard is implemented as a small core program along with several types of plugins: site adapters, formulas, and cell renderers/editors. The core contains functionality for displaying the data table and handling user interactions, and the table implementation is built using the [Handsontable](https://handsontable.com/) Javascript library.

![The architecture of the Wildcard system](media/architecture-clean.png)

Site adapters specify the bidirectional connection between the web page and its structured data representation.

For extracting data from the page and getting it into structured form, Wildcard provides ways to concisely express web scraping logic. For example, here is a code snippet for extracting the name of an Airbnb listing:

```typescript
  {
    fieldName: "name", // The name of the data field
    readOnly: true,    // Whether the user can edit the field
    type: "text",      // The type of the field
    // Given the DOM element for the entire listing,
    // return the DOM element representing this field
    el: (row) => row.querySelector(`.${titleClass}`),
  }
```

Sometimes important data is not shown in the UI, making it impossible to scrape from the DOM. To address this, we have also prototyped mechanisms for site adapters to observe AJAX requests made by the browser and extract data directly from JSON responses. This mechanism was used to implement the Airbnb Walkscore example, since latitude and longitude aren't shown in the Airbnb UI, but they are available in AJAX responses. We also plan to add the ability for site adapters to scrape data across multiple pages in paginated lists of results (as explored in prior work [@huynh2006]).

The site adapter also needs to support the reverse direction: sending updates from the table to the original page. Most DOM manipulation is not performed directly by the site adapter; instead, the adapter specifies how to find the divs representing data rows, and the core platform mutates the DOM to reflect the table state. The only exception is row actions (like favoriting an Airbnb listing), which are implemented as imperative Javascript functions that can can mutate the DOM, simulate clicks on buttons, etc.

# Design principles

The idea of spreadsheet-driven customization is guided by several design principles, inspired by prior work and our own experimentation. We think these principles can also broadly inform the design of end user programming tools, especially those that enable users to customize existing software.

## Expose a universal data structure

Today, most personal computing consists of using applications, which bundle together behavior and data to provide some set of functionality. While there are limited points of interoperability, applications generally are designed to operate independently of one another. Once a user has gotten past learning the basic idioms of modern computing like windows and scrollbars, most of the effort invested in learning to use one application does not carry over to using other applications.

Computing does not need to be organized this way. For example, UNIX offers a compelling alternative design: many small single-purpose utilities, all of which manipulate a universal format of text streams. The universal format creates a high degree of leverage from tools: users can get a lot of utility from deeply mastering a text editor and some text manipulation utilities, because these tools can be applied to nearly any task. As just one example, a user's preferred text editor can even serve as an interactive input mechanism in shell programs, e.g. for editing git commit messages.

Spreadsheet-driven customization aims to port this UNIX philosophy to the world of isolated Web applications, by creating a consistent data structure to represent the data inside many applications. In UNIX, the universal format is a text stream; in Wildcard, it is a relational table: a simple abstraction generic enough to describe the data used in many different applications. Because Wildcard maps the data from all applications to the table format, users can invest in mastering the Wildcard table editor, the formula language, and cell editor UIs, and reuse those same tools to customize many different applications.

This idea relates to Beaudouin-Lafon and Mackay's notion of _polymorphic interface instruments_ [@beaudouin-lafon2000]: UI elements that can be used in different contexts, like a color picker that can be used in many different drawing applications. diSessa has also noted the connection between literacy and the genericness of a medium. Textual literacy rests on the fact that writing can be adapted to many different genres and uses [@disessa2000]; if people needed to relearn reading and writing from scratch when switching from essays to emails, the medium would lose most of its potency. We think providing generic tools is especially important for software customization, because the most common barrier to customizing software is not having enough time [@mackay1991]—it's more likely that people will customize software regularly if they can reuse the same tool across many applications.

This design principle leads to several challenges. First, any universal abstraction has its constraints, and can't necessarily naturally express the data in every application. We plan to explore the limits of the table abstraction further, by trying to build adapters for more sites with varied data formats. We expect that many types of data can fit fairly naturally into tables: lists of search results, news articles, and messages can all be seen as relations. On sites that use document structures (e.g. Google Docs) or graph structures (e.g. social friend graphs), it may prove more challenging to map internal data to this abstraction.

Another challenge is ensuring a clear mapping in the user's mind between the spreadsheet and the original page. Wildcard provides live visual cues as the user navigates the data table (similar to the highlighting provided by DOM inspectors in browser developer tools). In our own usage, we have found that this live highlighting makes it very clear how the two representations map to each other.

## Low floor, high ceiling

Seymour Papert advocated for programming systems with a "low floor," making it easy for novices to get started, as well as a "high ceiling," providing a large range of possibilities for more sophisticated users [@resnick2016]. Our goal is for spreadsheet-driven customization to meet both of these criteria. Although we need more testing with real users to know for sure, we think Wildcard clearly provides a low floor, and likely has a flexible enough foundation to eventually provide a high ceiling.

One of the most interesting properties of spreadsheets is the amount of value they can provide to users who are aware of only a tiny sliver of their functionality. Not only can a novice perform some basic activities in a spreadsheet with almost no training (e.g., storing tables of numbers or computing simple sums), these activities are often actually valuable for the user! The fact that useful tasks can be performed early on supports the user's natural motivation to continue using the tool, and to eventually learn its more powerful features if needed [@nardi1991]. In contrast, many traditional programming systems require an enormous upfront investment of time and practice before someone is able to write a program that actually helps them achieve a real task.

As part of ensuring a low floor for spreadsheet-driven customization, we have focused on including genuinely valuable features for novices. For example, a user can sort a table with a single click, or simply type in some annotations. We would expect many Wildcard users to start out using these simpler features before potentially moving on to more sophisticated features like formulas.

Another aspect of providing a low floor is providing an "in-place toolchain" [@inkandswitch2019]—minimizing the effort of moving from using to customizing, by making customization tools available in the same environment where the user is already using the software. This quality is distinct from the level of technical skill needed to use the tool: for example, setting up a workflow trigger in an end user programming system like [IFTTT](https://ifttt.com/) does not require much technical skill, but does require leaving the user's normal software and entering a separate environment; conversely, running a Javascript snippet in the browser console requires programming skills, but can be done immediately and casually in the flow of using a website.


------------------------      ------------------         ----------------------------------------
                              *In-place*                   *Not in-place*
*End user friendly*           **Wildcard**               IFTTT
*Requires programming*        browser JS console          forking open source software
------------------------      -----------------          ----------------------------------------

Wildcard provides an in-place toolchain—on any site that supports Wildcard, the user is one click away from starting to tweak the site with minimal friction. There is no need for them to switch into another environment or figure out how to extract data from the page. Once the user starts editing, Wildcard also provides live feedback to help users understand the changes they are making. Even if a user isn't yet totally familiar with Wildcard, they can learn to use the system by trying things out and seeing what happens.

Since we have still only built several site adapters and demos, it's still too early to tell how high the ceiling is for the customizations that can be achieved with Wildcard, but we think that with enough operators the formula language could eventually support a wide variety of customizations. We plan to explore this aspect further by trying to solve more real problems with the system and observing where limitations emerge in practice.

## Build for multiple tiers of users

Real-world spreadsheet usage in offices is highly collaborative: most users just perform simple changes, while a few coworkers help with writing more complex formulas or even programming macros [@nardi1990]. Inspired by this, we aim to make spreadsheet-driven customization a collaborative activity that combines the different abilities of many users in a collaborative ecosystem.

The main way we do this is by separating website customization into two separate stages: structured data extraction, and using the resulting spreadsheet. The first stage is currently only available to programmers who can code site adapters in Javascript, whereas the second stage is available for any non-programmer end user. This architecture frees end users from needing to think about data extraction, and enables a community of end users to reuse the efforts of programmers building site adapters.

The group of users building adapters does not necessarily need to be limited only to programmers. In the future we might explore enabling end users to also create site adapters, drawing on related work on enabling end users to extract structured data from websites [@chasins2018; @huynh2006]. But even in that case, there would still be a separation between motivated, tech-savvy end users building adapters and more casual end users just using the spreadsheet view.

Another stakeholder to consider is the first party developers of the original software. Spreadsheet-driven customization does not depend on cooperation from first-party website developers: a third party programmer can write an adapter for any website, which can access any information available in the browser. On the other hand, if first parties were to expose structured data from their applications, it would avoid the need for adapters and generally make customization a lot easier. We think there are compelling reasons for first parties to consider doing this. Providing Wildcard support would allow users to build extensions to fulfill their own feature requests. It also would not necessarily require much effort: adding Wildcard support would be more straightforward for a first-party than a third-party because they have direct access to the structured data in the page. There is also precedent for first parties implementing an official client extension API in response to user demand: for several years, Google maintained an official extension API in Gmail for Greasemonkey scripts to use. ^[Incidentally, since then, third parties have continued to maintain stable Gmail extension APIs used by many browser extensions [@streak; @talwar2019], illustrating the potential of collaboratively maintaining third party adapters.]

# Related work

## Malleable software

In the broadest sense, Wildcard is inspired by systems aiming to make software into a dynamic medium where end users frequently create and modify software to meet their own needs, rather than only consuming applications built by programmers. These systems include Smalltalk [@kay1977], Hypercard [@hypercard2019] , Boxer [@disessa1986], Webstrates [@klokmose2015], and Dynamicland [@victor]. ^[The project's name Wildcard comes from the internal pre-release name for Hypercard, which doubly inspired our work by promoting both software modification by end users and the ideas behind the Web.]

While similar in high-level goals, Wildcard employs a different solution strategy from these projects: whereas they generally require building new software from scratch for that environment, Wildcard instead aims to maximize the malleability of already existing software. This approach has the pragmatic benefit of being immediately useful in more situations, although it also requires working within more rigid constraints.

With substantial future work, Wildcard could become more similar to these other projects, growing from a platform for tweaking existing software into a platform for building new software from scratch. This would likely end up resembling existing tools for building spreadsheet-driven applications (discussed more below), but with an extra focus on customizability by end users of the software.

## Web customization

Wildcard's goals are closely shared with other systems that provide interfaces in the browser for end users to augment and customize websites while using them.

### Structured augmentation

Wildcard's approach is most similar to a class of tools that identify structured data in a web page, and use that structure to support end user modification of the page.

Sifter [@huynh2006] enables users to sort and filter lists of data on web pages, providing a result similar to Wildcard's sort and filter functionality. The underlying mechanism is also similar: Sifter extracts structured data from the page to enable its user-facing functionality. Wildcard aims to extend this approach to support much broader functionality than just sorting and filtering. In support of this goal, Wildcard also shows the structured data table directly to the user, whereas Sifter only shows sort and filter controls, without revealing the underlying data table. The extraction mechanism is also different: Sifter uses a combination of automated heuristics and interactive user feedback to extract data, whereas Wildcard currently relies on programmers creating wrappers for extracting structured data, likely leading to higher quality extraction but on fewer sites.

Thresher [@hogue2005] enables users to create wrappers which map unstructured website content to Semantic Web content. Like Wildcard and Sifter, Thresher augments the experience of original page based on identifying structure: once semantic content has been identified, it creates context menus in the original website which allow users to take actions based on that content. Wildcard and Thresher share an overall approach but focus on complementary parts of the problem: Thresher aims to enable end users to create content wrappers, but the actions available on the structured data are created by programmers; conversely, Wildcard delegates wrapper creation to programmers but gives end users more flexibility to use the structured data in an open-ended way.

### Sloppy augmentation

"Sloppy programming" [@little2010] tools like Chickenfoot [@bolin2005] and Coscripter [@leshed2008] enable users to create scripts that perform actions like filling in text boxes and clicking buttons, without directly interacting with the DOM. Users express the desired page elements in natural, informal terms (e.g. writing "the username box" to represent the textbook closest to the label "username"), and then using heuristics to determine which elements most likely match the user's intent. This approach allows for expressing a wide variety of commands with minimal training, but it also has downsides. It is difficult to know whether a command will consistently work over time (in addition to changes to the website, changes to the heuristics can also cause problems), and it is not easy for users to discover the space of possible commands [@little2010].

Wildcard offers a sharp contrast to sloppy programming, instead choosing to expose a high degree of structure through the familiar spreadsheet table. Wildcard offers more consistency: for example, clicking a sort header will always work correctly as long as the site adapter is maintained. Wildcard also offers clearer affordances for what types of actions are possible, or, crucially, what actions are _not_ possible, which is useful to know. On the other hand, Wildcard cannot offer coverage of all websites, and has a narrower range of possible actions than sloppy tools. We expect that with enough site adapters and formulas, these downsides can be mitigated.

## Spreadsheet-based app builders

Prior work has made the powerful realization that a spreadsheet can serve as an end-user-friendly backing data store and computation layer for an interactive web application. Research projects like Object Spreadsheets [@mccutchen2016], Quilt [@benson2014], Gneiss [@chang2014], and Marmite [@wong2007], as well as commercial tools like Airtable Blocks [@zotero-79] and Glide [@zotero-81] allow users to view data in a spreadsheet table, compute over the data using formulas, and connect the table to a GUI. Because many users are already familiar with using spreadsheets, this way of creating applications tends to be far easier than traditional software methods; for example, in a user study of Quilt, many people were able to create applications in under 10 minutes, even if they expected it would take them many hours. 

Wildcard builds on this idea, but applies it to modifying existing applications, rather than building new applications from scratch. For many people, we suspect that tweaking existing applications provides more motivation as a starting point for programming than creating a new application from scratch.

An important design decision for tools in this space is how to deviate from traditional spreadsheets like Microsoft Excel or Google Sheets. Quilt and Glide use existing spreadsheet software as a backend, providing maximum familiarity for users, and even compatibility with existing spreadsheets. Gneiss has its own spreadsheet implementation with additional features useful for building GUIs. Marmite provides a live data view that resembles a spreadsheet, but programming is actually done using a separate data flow pane rather than spreadsheet formulas. (Marmite's approach led to some confusion in a user study, because users expected behavior more similar to spreadsheets [@wong2007].) Airtable deviates the furthest: although the user interface resembles a spreadsheet, the underlying structure is a relational database with typed columns. Wildcard's table is most similar to Airtable; the structure of a relational table is most appropriate for most data in websites, and we have not yet found a need for arbitrary untyped cells.

## Web scraping / data extraction

Web scraping tools focus on extracting structured data out of unstructured web pages. Web scraping is closely related to the implementation of Wildcard, but has different end goals: web scraping generally extracts static data for processing in another environment, whereas Wildcard modifies the original page by maintaining a bidirectional connection between the extracted data and the page.

Web scraping tools differ in how much structure they attempt to map onto the data. Some tools like Rousillon [@chasins2018] extract data in a minimally structured relational format; other tools like Piggy Bank [@huynh2005] more ambitiously map the data to a rich semantic schema. In Wildcard, we chose to avoid schemas, in order to minimize the work associated with creating a site adapter.

In the future, we might be able to integrate web scraping tools to help create more reliable site adapters for Wildcard with less work, and to open up adapter creation to end users. Sifter was built on top of the Piggy Bank scraping library, suggesting precisely this type of architecture where web scraping tools are used to support interactive page modification.

# Future work

There are still many open questions about spreadsheet-driven customization, which we hope to answer through targeted development and usage of the Wildcard prototype.

The most important question is whether the computational model can support a large variety of useful customizations. While initial demos are promising, we need to develop more site adapters and use cases to explore this further. We plan to continue privately testing the system with our own needs, and to eventually deploy the tool publicly, once the API is stable enough and can support a critical mass of sites and use cases. We also plan to run usability studies to evaluate and improve the design of the tool.

We suspect that two areas of the current model may prove too limiting. First, Wildcard's data model only shows a single table at a time, without any notion of relationships between tables. A richer data model with foreign keys might be necessary to support certain use cases. For designing a tabular interface on top of a richer data model, we could learn from the interface of Airtable which shows related objects in a table cell, or add nested rows as used in other systems [@mccutchen2016; @bakke2016].

Second, there is no mechanism for end users to express imperative workflows (e.g. "click this button, and then..."); they can only write formulas that return data and then inject the resulting data into the page. If it proves useful, we might consider adding a system for expressing workflows like this, although it would substantially alter the computational model and it's not clear how it would fit together with the existing table view.

Another open question is how efficiently site adapters can be created for real websites. By making adapters for sites with different types of data in different domains, we plan to explore how automated heuristics can speed up the adapter creation process, and to create abstractions that make it easier for programmers to efficiently create new robust adapters.

# Conclusion

In this paper, we have presented _spreadsheet-driven customization_, a way to make software customization more accessible to end users by showing the data inside the application in a spreadsheet. We hope that this technique contributes to making the Web into a more dynamic medium that users can mold to their own needs.

We plan to continue developing the Wildcard prototype and to eventually deploy it as an open-source tool. To receive future updates on Wildcard and notifications about a public release, [sign up for the email newsletter]().

We are also looking for private beta testers. If you have an idea for how you might want to use Wildcard, please [get in touch](mailto:glitt@mit.edu). We would love to hear about your needs and help find ways to use Wildcard to solve them.
