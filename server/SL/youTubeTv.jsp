<html>
<head>
</head>
<%
  String key = request.getParameter( "key");
%>
<body bgcolor="#000000">
<object width="960" height="745">
  <param name="movie" value="http://www.youtube.com/v/<%= key %>&hl=en_US&fs=1&"></param><param name="allowFullScreen"
                                                                                                 value="true"></param>
  <param name="allowscriptaccess" value="always"></param><embed
        src="http://www.youtube.com/v/<%= key %>&hl=en_US&fs=1&autoplay=1&" type="application/x-shockwave-flash"
        allowscriptaccess="always" allowfullscreen="true" width="960" height="745"></embed></object>
</body>
</html>