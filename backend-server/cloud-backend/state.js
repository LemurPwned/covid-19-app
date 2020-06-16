const dfClient = require('./dialogFlowClient')
const model = require('./algo')
const fs = require('fs');
const request = require('request');


const Actions = {
    Location: 0,
    MultiChoice: 1,
    Text: 2,
    Twitter: 3
}

const Intents = {
    WelcomeIntent: "WelcomeIntent",
    AfterWelcomeNotWell: "AfterWelcomeNotWell",
    AfterWelcomeWell: "AfterWelcomeWell",
    NotWellIntent: "NotWellIntent",
    EverythingIsFineIntent: "EverythingIsFineIntent",
    SomethingIsNotFineIntent: "SomethingIsWrongIntnet",
    WeatherIntent: "weather"
}

let allSymptoms = ['fever', 'cough', 'general malaise', 'throat pain',
    'difficulty in breathing', 'headache', 'chill', 'runny nose',
    'joint pain', 'cough with sputum', 'diarrhea', 'muscle pain',
    'pneumonia', 'nausea', 'loss of appetite', 'chest discomfort',
    'abdominal pain', 'flu', 'respiratory distress', 'heavy head',
    'thirst', 'whole body pain', 'back pain', 'reflux'] // example one


const symptomsCSV = './mod_probs_counter.json'
let modProbsCounter = JSON.parse(fs.readFileSync(symptomsCSV, 'utf8'));

function formulateState(state, intent, messageText, messageChoices, responseExpected) {
    /**
     * Formulates Dialogflow state using the schema defined for the system
     */
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
    /**
     * This is a default state of the system. 0 state and revert state
     */
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
     * Call model here and ask for probability given symptoms
     */
    let riskThreshold = 1.1
    // let calculatedRisk = 0.7 // call the model here 

    let calculatedRisk = model.calculateProbability(
        modProbsCounter, mobileRequest.userInput.choices, 0.1
    ) * 100

    if (calculatedRisk > riskThreshold) {
        // high risk
        // agitated response 
        // put the hospital info 
        // some default resonse Fallback
        let msg = `You are found to be in high risk group! Risk index: ${calculatedRisk.toFixed(3)}\n`
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
        let responseState = formulateState(
            Math.random() > 0.5 ? Actions.Twitter : Actions.Text,
            Intents.EverythingIsFineIntent,
            msg,
            null,
            false
        );
        res.status(200).set('Content-Type', 'application/json')
        res.json(responseState)
    }
}

function onNotWellIntent(body, dfResponse, res) {
    /**
     * Upon not well intent from DialogFlow, we ask the user
     * to provide the subset of symptoms she/he is experiencing.
     */
    const n = 6
    const shuffled = allSymptoms.sort(() => 0.5 - Math.random());
    // Get sub-array of first n elements after shuffled
    let selected = shuffled.slice(0, n);
    let responseState = formulateState(
        Actions.MultiChoice,
        dfResponse.intent.displayName,
        "Mark your symptoms, confirm with typing in OK.",
        selected,
        true
    )
    res.status(200).set('Content-Type', 'application/json')
    res.json(responseState)
}


function onDefaultState(body, dfResponse, res) {
    /**
     * Default state copies the response from the 
     * Dialogflow Intent and fullfillments.
     */

    let responseState = formulateState(
        Actions.Text,
        dfResponse.intent.displayName,
        dfResponse.fulfillmentText,
        null,
        true
    )
    res.status(200).set('Content-Type', 'application/json')
    res.json(responseState)
}


function onWeatherState(body, dfResponse, res) {
    /**
     * Run OpenWeatherAPI 
     */
    console.log(dfResponse.fulfillmentText)
    let city = JSON.parse(dfResponse.fulfillmentText).address.trim()
    let query = "https://api.openweathermap.org/data/2.5/weather?q=" + city + "&appid=4526d487f12ef78b82b7a7d113faea64"
    query = encodeURI(query)
    request(query, { json: true }, (err, _, body) => {
        if (err) {
            console.log(err)
            res.status(404).json({ "error": err });
            return
        } else {
            console.log(body)
            if (body.cod == 404) {
                res.status(body.cod).send(body)
            } else {
                let weatherText = `Weather in ${city}: ${body["weather"][0]["main"]} -- ${body["weather"][0]["description"]}`
                weatherText += `\nTemperature: ${body["main"]["temp"]}F!`
                console.log(weatherText)
                let responseState = formulateState(
                    Actions.Text,
                    dfResponse.intent.displayName,
                    weatherText,
                    null,
                    false
                )
                res.status(200).set('Content-Type', 'application/json')
                res.json(responseState)
            }
        }
    });
}



async function uponStateRequest(mobileRequest, res) {
    /**
     *  Mobile request defines a state 
     * and the user response to that state
     */
    console.log("Processing request!")
    console.log(mobileRequest)
    if (mobileRequest.userInput.choices != null) {
        console.log(mobileRequest.userInput.choices)
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
            case Intents.AfterWelcomeNotWell:
                console.log("Not well response")
                onNotWellIntent(mobileRequest, dfResponse, res)
                break
            case Intents.WeatherIntent:
                console.log("Weather intent")
                onWeatherState(mobileRequest, dfResponse, res)
                break
            default:
                onDefaultState(mobileRequest, dfResponse, res)
                console.log("Default response")
                break
        }
    }


}

module.exports = {
    uponStateRequest: uponStateRequest
}