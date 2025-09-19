# Fetch the access token
curl --request POST \
  --url "$AICORE_AUTH_URL/oauth/token" \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data grant_type=client_credentials \
  --data "client_id=$AICORE_CLIENT_ID" \
  --data "client_secret=$AICORE_CLIENT_SECRET"

# You shall receive an access token and please export it
export TOKEN=<Token here>

# Get models available
curl --location "$AICORE_BASE_URL/v2/lm/scenarios/foundation-models/models" \
--header "AI-Resource-Group: $AICORE_RESOURCE_GROUP" \
--header "Authorization: Bearer $TOKEN"

# Get scenarios
curl --location "$AICORE_BASE_URL/v2/lm/scenarios" \
--header "AI-Resource-Group: $AICORE_RESOURCE_GROUP" \
--header "Authorization: Bearer $TOKEN"

# Get configuration
curl --location "$AICORE_BASE_URL/v2/lm/configurations" \
--header "AI-Resource-Group: $AICORE_RESOURCE_GROUP" \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $TOKEN" \
--data '{
  "name": "JacksonWang",
  "executableId": "azure-openai",
  "scenarioId": "foundation-models",
  "versionId": "0.0.1",
  "parameterBindings": [
    {
      "key":"modelName",
      "value":"gpt-5-mini"
    },
    {
      "key": "modelVersion",
      "value": "latest"
    }
  ]
}'

# You may receive a response that returns config id: {"id": "<The Config ID>", "message": "Configuration created"}
export CONFIG_ID=<Config ID here>

# Create your own deployment
curl --location "$AICORE_BASE_URL/v2/lm/deployments" \
--header "AI-Resource-Group: $AICORE_RESOURCE_GROUP" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer $TOKEN" \
--data "{
\"configurationId\": \"$CONFIG_ID\"
}"

# You may receive a response to {"id": "<The Deployment ID>", "deploymentUrl": "", "message": "Deployment scheduled.", "status": "UNKNOWN"}
# Note: Using the provided DEPLOY_ID environment variable instead of exporting a new one

# Check the status of a deployment
curl --location "$AICORE_BASE_URL/v2/lm/deployments/$DEPLOY_ID" \
--header "AI-Resource-Group: $AICORE_RESOURCE_GROUP" \
--header "Authorization: Bearer $TOKEN"

# Test the deployment
curl --request POST \
  --url "$AICORE_BASE_URL/v2/inference/deployments/$DEPLOY_ID/converse" \
  --header "authorization: Bearer $TOKEN" \
  --header "content-type: application/json" \
  --header "AI-Resource-Group: $AICORE_RESOURCE_GROUP" \
  --header "AI-Client-Type: GenAI Hub SDK (Python)" \
  --data '{
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "text": "This is a test. Respond strictly as '\''I am successfully deployed'\''"
          }
        ]
      }
    ],
    "inferenceConfig": {
      "temperature": 0.5,
      "topP": 0.9,
      "maxTokens": 250
    }
  }'



curl --request POST \
   --url 'https://api.ai.prod.eu-central-1.aws.ml.hana.ondemand.com/v2/inference/deployments/d7798b66021df731/chat/completions' \
  --header "authorization: Bearer $TOKEN" \
  --header "content-type: application/json" \
  --data '{ "model": "gpt-5-mini", "messages": [ { "content": "This is a test. Respond strictly as '\''I am successfully deployed'\''", "role": "user" } ], "temperature": 0.5, "frequency_penalty": 1, "presence_penalty": -1, "max_tokens": 250 }'

