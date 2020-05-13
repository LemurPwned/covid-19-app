
const dfClient = require('./DialogFlowClient')


const States = {
    Location: 1,
    MultiChoice: 2,
    Text: 3,
    Twitter: 4
}

let allSymptoms = ["fever", "cough", "pain", "headache", "cold", "backpain"] // example one

let currentChainState = 0
let riskChain = {
    0: 'high',
    1: 'normal/undefined',
    2: 'low'
}

function formulateState(state, messageText, messageChoices, responseExpected) {
    let responseState = {
        "State": state,
        "messageText": messageText,
        "messageChoices": messageChoices,
        "responseExpected": responseExpected
    }
    return responseState
}


function onZeroState(res) {
    // send Hello to DF 
    let dfResponse = "Back"
    let responseState = formulateState(
        States.Text,
        dfResponse,
        null,
        true
    );
    res.status(200).set('Content-Type', 'application/json')
    res.json(responseState)
    // let result = await dfClient.
}

function updateState(params) {

}


function onYesNoQuestion() {
    // ask dialogflow
    let dfResponse = "Well then could you...?"
    let responseState = formulateState(
        States.Text,
        dfResponse,
        null,
        true
    );
    res.status(200).set('Content-Type', 'application/json')
    res.json(responseState)
}

function onSymptomSelection() {
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
        let msg = "You are found to be in high risk group!"
        msg += "This is the closest hospital"
        return formulateState(
            States.Location,
            msg,
            null,
            false
        )
    } else {
        // low threshold 
        // normal response 
        let msg = "Fortunately your health is ok!"
        return formulateState(
            Math.random() > 0.5 ? States.Twitter : States.Text,
            msg,
            null,
            false
        );
    }
}

function onNotWellIntent() {
    const n = 4
    const shuffled = allSymptoms.sort(() => 0.5 - Math.random());
    // Get sub-array of first n elements after shuffled
    let selected = shuffled.slice(0, n);
    return formulateState(
        States.MultiChoice,
        "Did you experience any of those symptoms?",
        selected,
        true
    )
}



function uponStateRequest(mobileRequest) {
    /**
     *  Mobile request defines a state 
     * and the user response to that state
     */

    var lastMobileState = mobileRequest["state"]
    switch (lastMobileState) {
        case States.Location:
            break;
        case States.MultiChoice:
            break
        case States.Text:
            break
        case Twitter:
            break
        default:
            break

    }

}


