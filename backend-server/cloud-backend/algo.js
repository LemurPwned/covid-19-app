
const csv = require('csv-parser');
const Combinatorics = require('js-combinatorics')

// Uncomment here to get detailed debug
// const fs = require('fs');
// const symptomsCSV = './mod_probs_counter.json'
// let modProbsCounter = JSON.parse(fs.readFileSync(symptomsCSV, 'utf8'));
const D = 24 // unique symptoms
function symptomProbability() {
    // test 
    let res = calculateProbability(mod_probs_counter, ['cough', 'fever', 'diziness'])
    console.log(res)
    res = calculateProbability(mod_probs_counter, ['fever', 'cough', 'difficulty in breathing'])
    console.log(res)
}

function laplaceSmoothing(mod_probs_counter, sortedCombination, sampleNum, smoothing=0){
    let probs = 0 
    const joinedSympt = sortedCombination.join(',')
    if (mod_probs_counter.hasOwnProperty(joinedSympt)){
        probs += mod_probs_counter[joinedSympt]
    }
    return(probs + smoothing)/(smoothing* sampleNum + D)
}


function calculateProbability(mod_probs_counter, symptomList, baselineOffset = 0) {
    let s = 0
    let keySize = Object.keys(mod_probs_counter).length
    for (let k = 1; k <= symptomList.length; k++) {
        symptomCombs = Combinatorics.combination(symptomList, k);
        while(a = symptomCombs.next()) {
            sortedCombination = a.sort()
            a = laplaceSmoothing(mod_probs_counter, sortedCombination, keySize)
            s += a
        }
    }
    return s
}


module.exports =  {
    calculateProbability: calculateProbability
}