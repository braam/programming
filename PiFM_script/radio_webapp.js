var http = require('http');
    url = require('url');
    port = '8080';
const sys = require('sys');
      exec = require('child_process').exec;

var server = http.createServer(function(req, res) {
    var page = url.parse(req.url).pathname;
    console.log('path req:' + page);
    res.writeHead(200, {'Content-Type': 'text/html'});

    if (page == '/') {
        res.write('<html><head><title>FM BroadCast</title></head><body><button onclick="window.open(\'http://192.168.10.24:8080/play\',\'_self\');">Start FM</button></body></html>');
    }
    else if (page == '/play') {
        res.write('Broadcast started..');
        exec("bash /home/pi/radio/JASPER.sh", puts);
    }
    else {
        res.write('404 - Page Not Found');
    }
    res.end();
});

function puts(error, stdout, stderr) { 
    sys.puts(stdout);
}

server.listen(port);
console.log("listening to server on port:", port);
