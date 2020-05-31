const state = require("./state")
const express = require('express')

// Create a new instance of express
const app = express()

// Tell express to use the body-parser middleware and to not parse extended bodies
// app.use(bodyParser.urlencoded({ extended: false }))
app.use(express.json());
// Route that receives a POST request to /sms
app.post('/response', function (req, res) {
  const body = req.body

  // const jsonBody = JSON.parse(body);
  state.uponStateRequest(body, res).catch(
    (err) => {
      console.log(`Error ${err}`)
      res.status(404).send(err)
    }
  )
})

// Tell our app to listen on port 3000
app.listen(3000, function (err) {
  if (err) {
    throw err
  }

  console.log('Server started on port 3000')
})





