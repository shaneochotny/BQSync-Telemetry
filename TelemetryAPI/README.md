### Description
Simple HTTP API to retreive telemetry messages in JSON and send to Azure Event Hubs or Fabric Eventstream.

### HTTP POST Format
Messages can be send as an HTTP POST in JSON. The JSON object can contain any values but the parent in a single object, not an array.

```
HTTP POST: https://FUNCTION_APP_SERVICE.azurewebsites.net/telemetry

{
    "activity": "install",
    "id": "912ec803b2ce49e4a541068d495ab570",
    "settings": ["setting 1", "setting 2", "setting 3"],
    "options": [
        {
            "key_1": "value_1"
        }
    ]
}
```

### Requirements
- C# .NET 9.0
- Function Tools 4

### Configuration
An **EventHubConnectionString** environment variable needs to be created in the App Service with the correct connection string. Fabric Eventstream Custom Endpoint will use an automatically generated Namespace and Event Hub name (i.e. es_8cdeae0e-f33c-4598-85b3-d1d18b72d221).

Example:
```
Endpoint=sb://EVENT_HUB_NAMESPACE.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=e94VBrUge34/Yubi6X24u7UU9dkrdpNWk+ArAxYuHjQ=;EntityPath=EVENT_HUB_NAME
```

### Deployment
Deploy via VSCode.