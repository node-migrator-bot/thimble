Painlessly stitch up your web applications

## Introduction ##

Thimble allows you to develop your web application in patches and stitch it up at the end. Today we have to walk all around our code to make even the smallest changes to our application. We head to the views/ folder to modify our HTML. We then head to the public/stylesheets to find our CSS. Now we have to go to public/scripts to make a change to our Javascript. If we're working with templates, lets switch into our public/templates folder. Since we're all astute developers we should also head over to /tests to modify our test cases. In a big application this is a ton of context switching for every change. Even worse, this becomes exponentially harder when we start working with compiled languages and preprocessors like Coffeescript, Stylus, and LESS. 
* templates too.


Furthermore, this is not how we think about things in the real world. An objects structure should not be in one place, its style someplace else, and its actions someplace else. It should all be self-contained.

So why is our directory structure like this? Us front-end developers were never given a nice way to break things up. We were never given includes in our code. 

We change the structure with our view, modify the javascript logic and style in the public folder, 



Thimble has two components, the server and the builder. The server is used for development and compiles everything at runtime. 


The builder is used before you push to production, it will asynchronously crawl through your application, pulling out all the asset tags, rendering them, minifying them, and moving them to a more appropriate place in the application. This means that CSS files will be placed at the bottom of the `<head>` and `<script>` tags will be moved to the 
