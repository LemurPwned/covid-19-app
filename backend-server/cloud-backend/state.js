const dfClient = require('./dialogFlowClient')

const Actions = {
    Location: 0,
    MultiChoice: 1,
    Text: 2,
    Twitter: 3
}

const Intents = {
    WelcomeIntent: "WelcomeIntent",
    NotWellIntent: "NotWellIntent",
    EverythingIsFineIntent: "EverythingIsFineIntent",
    SomethingIsNotFineIntent: "SomethingIsWrongIntnet",
}

let allSymptoms = ["fever", "cough", "pain", "headache", "cold", "backpain"] // example one

function formulateState(state, intent, messageText, messageChoices, responseExpected) {
    let responseState = {
        "state": state,
        "intent": intent,
        "messageText": messageText,
        "messageChoices": messageChoices,
        "responseExpected": responseExpected
    }
    return responseState
}

async function onZeroState(body, dfResponse, res) {
    let responseState = formulateState(
        Actions.Text,
        dfResponse.intent.displayName ? dfResponse.intent.displayName : "None",
        dfResponse.fulfillmentText,
        null,
        true
    );
    res.status(200).set('Content-Type', 'application/json')
    res.json(responseState)
}

function onYesNoQuestion() {
    // ask dialogflow
    let dfResponse = "Well then could you...?"
    let responseState = formulateState(
        Actions.Text,
        dfResponse,
        null,
        true
    );
    res.status(200).set('Content-Type', 'application/json')
    res.json(responseState)
}

function onSymptomSelection(mobileRequest, dfResponse, res) {
    /**
     * Call model here and ask for prob
     */
    let riskThreshold = 0.3
    let calculatedRisk = 0.7 // call the model here 

    if (calculatedRisk > riskThreshold) {
        // high risk
        // agitated response 
        // put the hospital info 
        // some default resonse Fallback
        let msg = `You are found to be in high risk group! Pr: ${calculatedRisk}\n`
        msg += "This is the closest hospital!"
        let responseState = formulateState(
            Actions.Location,
            Intents.SomethingIsNotFineIntent,
            msg,
            null,
            false
        )
        res.status(200).set('Content-Type', 'application/json')
        res.json(responseState)
    } else {
        // low threshold 
        // normal response 
        let msg = "Fortunately your health is ok!"
        return formulateState(
            Math.random() > 0.5 ? Actions.Twitter : Actions.Text,
            msg,
            null,
            false
        );
    }
}

function onNotWellIntent(body, dfResponse, res) {
    const n = 4
    const shuffled = allSymptoms.sort(() => 0.5 - Math.random());
    // Get sub-array of first n elements after shuffled
    let selected = shuffled.slice(0, n);
    let responseState = formulateState(
        Actions.MultiChoice,
        dfResponse.intent.displayName,
        dfResponse.fulfillmentText,
        selected,
        true
    )
    res.status(200).set('Content-Type', 'application/json')
    res.json(responseState)
}

async function uponStateRequest(mobileRequest, res) {
    /**
     *  Mobile request defines a state 
     * and the user response to that state
     */

    if (mobileRequest.userInput.choices != null) {
        onSymptomSelection(mobileRequest, null, res);
    }
    else {
        let dfResponse = await dfClient.retrieveDiaglogFlowQuery(
            mobileRequest['userInput']['message']
        )
        console.log(dfResponse.intent)
        switch (dfResponse.intent.displayName) {
            case Intents.WelcomeIntent:
                console.log("Sending welcome response")
                onZeroState(mobileRequest, dfResponse, res)
                break
            case Intents.NotWellIntent:
                console.log("Not well response")
                onNotWellIntent(mobileRequest, dfResponse, res)
                break
            case Intents.EverythingIsFineIntent:
                console.log("All fine response")
                break
            case Actions.Twitter:
                break
            default:
                break

        }
    }
}

module.exports = {
    uponStateRequest: uponStateRequest
}