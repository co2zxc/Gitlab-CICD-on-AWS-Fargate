<?php
    
http_response_code(400);
//var_dump(http_response_code());
header("HTTP/1.1 400 Bad Request");
echo "<td align='center'><h1>400 Bad Request</h1></td>";

?>