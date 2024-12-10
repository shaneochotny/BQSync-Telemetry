### Description
Bicep template for the environment.

### Deployed Resources
- Function App (without the build)
- Function App Storage Account
- Log Analytics
- Application Insights
- Event Hubs (optional)

### Configuration
Event Hubs will be deployed by default. If you want to emit to Fabric Eventstream, set **deployEventHubs = false** and specify the Fabric Eventstream Custom Endpoint connection string in **eventHubConnectionString**.

Example:
```
Endpoint=sb://EVENT_HUB_NAMESPACE.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=e94VBrUge34/Yubi6X24u7UU9dkrdpNWk+ArAxYuHjQ=;EntityPath=EVENT_HUB_NAME
```

### Deployment
```
az deployment sub create --template-file main.bicep --parameters parameters.bicepparam --name "BQSync-Telemetry" --location eastus2
```