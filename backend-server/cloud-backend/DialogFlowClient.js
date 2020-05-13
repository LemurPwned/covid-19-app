const dialogflow = require('dialogflow');
const uuid = require('uuid');

//dlaczego jak wywoluje ta funkcje to config mam undefined? musze w argumencie exportowaną zmienna przekazac
const config = require('./credentials/newagent-jqwvxl-2cd321decf71.json');

console.log(config)
/**
 * Send a query to the dialogflow agent, and return the query result.
 * @param {string} projectId The project to be used
 */
async function requestDialogFlow(projectId = 'your-project-id', cred) {
  console.log("Starting invocation...");
  let result = null;

  // A unique identifier for the given session
  const sessionId = uuid.v4();
  try {
    // Create a new session
    // const sessionClient = new dialogflow.SessionsClient({
    //   keyFilename: './credentials/newagent-jqwvxl-2cd321decf71.json'
    // });

    let privateKey = this.cred.private_key;
    let clientEmail = this.cred.client_email;
    let c = {
      credentials: {
        private_key: privateKey,
        client_email: clientEmail
      }
    }

    const sessionClient = new dialogflow.SessionsClient(c);

    const sessionPath = sessionClient.sessionPath(projectId, sessionId);

    // The text query request.
    const request = {
      session: sessionPath,
      queryInput: {
        text: {
          // The query to send to the dialogflow agent
          text: 'hello',
          // The language used by the client (en-US)
          languageCode: 'en-US',
        },
      },
    };

    // Send request and log result
    const responses = await sessionClient.detectIntent(request);

    console.log('Detected intent');
    result = responses[0].queryResult;
    console.log(`  Query: ${result.queryText}`);
    console.log(`  Response: ${result.fulfillmentText}`);
    if (result.intent) {
      console.log(`  Intent: ${result.intent.displayName}`);
    } else {
      console.log(`  No intent matched.`);
    }
  }
  catch (err) {
    console.error(err.name);
    console.error(err.message);
  }

  return result;
}

module.exports = { requestDialogFlow: requestDialogFlow, cred: config }