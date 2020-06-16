const dialogflow = require('dialogflow');
const uuid = require('uuid');


const config = require('./credentials/newagent-jqwvxl-2cd321decf71.json');

console.log(config)

const projectId = 'newagent-jqwvxl'
const sessionId = uuid.v4();
const sessionClient = new dialogflow.SessionsClient();
const sessionPath = sessionClient.sessionPath(projectId, sessionId);

async function retrieveDiaglogFlowQuery(queryText) {
  // The text query request.
  const request = {
    session: sessionPath,
    queryInput: {
      text: {
        // The query to send to the dialogflow agent
        text: queryText,
        // The language used by the client (en-US)
        languageCode: 'en-US',
      },
    },
  };

  
  // Send request and log result
  const responses = await sessionClient.detectIntent(request);
  console.log('Detected intent');
  const result = responses[0].queryResult;
  console.log(`  Query: ${result.queryText}`);
  console.log(`  Response: ${result.fulfillmentText}`);
  if (result.intent) {
    console.log(`  Intent: ${result.intent.displayName}`);
  } else {
    console.log(`  No intent matched.`);
  }
  return result;

}

module.exports = {
  retrieveDiaglogFlowQuery: retrieveDiaglogFlowQuery
}