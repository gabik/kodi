<?php header('Access-Control-Allow-Origin: *'); ?>

<HTML>
<HEAD>
<script src="//code.jquery.com/jquery-1.11.3.min.js"></script>
<SCRIPT>
function sendok() {
       var sendInfo = {
           jsonrpc: "2.0",
           method: "Input.Select",
           id: "1"
       };

       $.ajax({
           type: "POST",
           url: "http://10.0.0.7/jsonrpc?Input.Select",
           dataType: "json",
           success: function (msg) {
               if (msg) {
                   alert("ok");
               } else {
                   alert("error");
               }
           },

           data: sendInfo
       });
}
</SCRIPT>
<BODY>
<Button onclick=sendok()>Send</Button>
</BODY></HTML>
