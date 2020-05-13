// var DialogFlowClient = require("./DialogFlowClient");
// const http = require('http');

// const hostname = '127.0.0.1';
// const port = 3000;
// const projectId = "newagent-jqwvxl";

// const server = http.createServer((req, res) => {
//   res.statusCode = 200;
//   res.setHeader('Content-Type', 'text/plain');
//   res.end('Hello World');



// });

// let result = DialogFlowClient.requestDialogFlow(projectId, DialogFlowClient.cred);
// server.listen(port, hostname, () => {
//   console.log(`Server running at http://${hostname}:${port}/`);
// });


// function handleMobilePOST(req, res) {

// }

const state = require("./state")
const express = require('express')
const bodyParser = require('body-parser')

// Create a new instance of express
const app = express()

// Tell express to use the body-parser middleware and to not parse extended bodies
app.use(bodyParser.urlencoded({ extended: false }))

// Route that receives a POST request to /sms
app.post('/response', function (req, res) {
  const body = req.body.Body
  res.set('Content-Type', 'application/json')
  res.send(`You sent: ${body} to Express`)
  const jsonBody = JSON.parse(body);
  state.updateStateRequest(jsonBody);
})

// Tell our app to listen on port 3000
app.listen(3000, function (err) {
  if (err) {
    throw err
  }

  console.log('Server started on port 3000')
})





