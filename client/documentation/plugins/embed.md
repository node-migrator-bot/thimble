### Embed ###

Embed compiles your client-side templates into functions. When the embed plugin runs, it looks for `script` tags that have `type = "text/template"`, compiles them, and attaches them to the `namespace`.`template` object, where both `namespace` and `template` are configurable. Therefore when you run your application, your templates are ready to be called.

For example:

    <script src = "contact.mu" type = "text/template"></script>
    
Will compile to:

    <script type = "text/javascript">
      window.JST['contact'] = 
        function(locals) { ... };
    </script>
    
That can be called by: 
    
    window.JST['contact']({
      name : "Matt Mueller",
      age  : 22
    });

> Note: By default, your templates are attached to the `window.JST` object.