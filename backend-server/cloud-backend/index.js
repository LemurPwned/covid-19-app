var DialogFlowClient = require("./DialogFlowClient");
const http = require('http');

const hostname = '127.0.0.1';
const port = 3000;
const projectId = "newagent-jqwvxl";

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World');
});

let result = DialogFlowClient.requestDialogFlow(projectId, DialogFlowClient.cred);

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});