'use strict';
const state = require("./state")

exports.postResponse = (req, res) => {
  const body = req.body

  // const jsonBody = JSON.parse(body);
  state.uponStateRequest(body, res).catch(
    (err) => {
      console.log(`Error ${err}`)
      req.statusCode(404).send(err)
    }
  )
};