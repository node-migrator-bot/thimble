<html>
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8">
    <title>Hogan Templating</title>
  </head>
  <body>
    <!-- Should be replaced by the server -->
    hello from the {{computer}}!
    
    <br /><br />
    
    <!-- Client side mustachin' -->
    <script src="template.mu" type="text/template" charset="utf-8"></script>
    <script type="text/javascript" charset="utf-8">
      var locals = {
        computer : "client"
      };
      
      var str = JST['template'](locals);
      
      document.write(str);
    </script>
    

  </body>
</html>