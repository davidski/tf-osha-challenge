// Region for ML configuration
AWS.config.region = 'us-east-1';

// Configure the credentials provider to use your identity pool
AWS.config.credentials = new AWS.CognitoIdentityCredentials({
    IdentityPoolId: 'us-west-2:8496cbfb-ce1d-41d4-8bb9-940412bebd2b',
});

// Make the call to obtain credentials
AWS.config.credentials.get(function(){

    // Credentials will be available when this function is called.
    var accessKeyId = AWS.config.credentials.accessKeyId;
    var secretAccessKey = AWS.config.credentials.secretAccessKey;
    var sessionToken = AWS.config.credentials.sessionToken;

});

var machinelearning = new AWS.MachineLearning();
machinelearning.addTags(params, function (err, data) {
  if (err) console.log(err, err.stack); // an error occurred
  else     console.log(data);           // successful response
});

var params = {
  MLModelId: 'ml-oKHtcVCiEit',
  PredictEndpoint: 'STRING_VALUE',
  Record: { 
    attribute1: form.attribute1.text,
    attribute2: form.attribute2.text,
    attribute3: form.attribute3.text,
    attribute4: form.attribute4.text,
    attribute5: form.attribute5.text
  }
};

machinelearning.predict(params, function(err, data) {
  if (err) console.log(err, err.stack); // an error occurred
  else     updatePredict(data);           // successful response
});

var updatePredict = fnuction(data) {
  form.text = data.Prediction.Details.DetailsAttributes.PREDICTIVE_MODEL_TYPE;
  form.text = data.Prediction.Details.DetailsAttributes.ALGORITHM;
  form.PredictedLabel = data.Prediction.PredictedLabel;
  form.PredictedScores = data.Prediction.PredictedScores;
  form.PredictedValue = data.Prediction.PredictedValue;
  form.predictedLabel = data.Prediction.predictedLabel;
  form.predictedValue = data.Prediction.predictedValue;
  form.predictedScores = data.Prediction.predictedScores;
  form.details= data.Prediction.details;
}
