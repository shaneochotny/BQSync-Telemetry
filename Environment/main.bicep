targetScope='subscription'

param environmentPrefix string
param resourceNameSuffix string
param resourceGroupName string
param environmentNameTag string
param applicationNameTag string
param purposeDescriptionTag string
param azureRegion string
param deployEventHubs bool
param eventHubConnectionString string

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Resource Group
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Resource Group:
//    Organization for all the resources
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${toUpper(environmentPrefix)}-${resourceGroupName}'
  location: azureRegion
  tags: {
    Environment: environmentNameTag
    Application: applicationNameTag
    Purpose: purposeDescriptionTag
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Application
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Function App:
//    APIs
module functionApp 'App/functionApp.bicep' = {
  name: 'functionApp'
  scope: resourceGroup
  params: {
    azureRegion: azureRegion
    environmentPrefix: environmentPrefix
    resourceNameSuffix: resourceNameSuffix
    environmentNameTag: environmentNameTag
    applicationNameTag: applicationNameTag
    purposeDescriptionTag: 'Function APIs'
    deployEventHubs: deployEventHubs
    eventHubConnectionString: eventHubConnectionString
  }

  dependsOn: [
    eventHubs
    applicationInsights
    functionAppStorage
  ]
}

// Azure Storage:
//    Function App Storage
module functionAppStorage 'App/functionAppStorage.bicep' = {
  name: 'functionAppStorage'
  scope: resourceGroup
  params: {
    azureRegion: azureRegion
    environmentPrefix: environmentPrefix
    resourceNameSuffix: resourceNameSuffix
    environmentNameTag: environmentNameTag
    applicationNameTag: applicationNameTag
    purposeDescriptionTag: 'Function App Storage'
  }
}

// Event Hubs:
//    Telemetry
module eventHubs 'EventHubs/eventHubs.bicep' = if(deployEventHubs) {
  name: 'eventHubs'
  scope: resourceGroup
  params: {
    azureRegion: azureRegion
    environmentPrefix: environmentPrefix
    resourceNameSuffix: resourceNameSuffix
    environmentNameTag: environmentNameTag
    applicationNameTag: applicationNameTag
    purposeDescriptionTag: 'Telemetry'
  }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Monitoring
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Azure Log Analytics:
//    Logging and telemetry for all Azure services in the environment
module logAnalytics 'Monitoring/logAnalytics.bicep' = {
  name: 'logAnalytics'
  scope: resourceGroup
  params: {
    azureRegion: azureRegion
    environmentPrefix: environmentPrefix
    resourceNameSuffix: resourceNameSuffix
    environmentNameTag: environmentNameTag
    applicationNameTag: applicationNameTag
    purposeDescriptionTag: 'Environment Logging & Monitoring'
  }
}

// Azure Application Insights:
//    Application-level monitoring
module applicationInsights 'Monitoring/applicationInsights.bicep' = {
  name: 'applicationInsights'
  scope: resourceGroup
  params: {
    azureRegion: azureRegion
    environmentPrefix: environmentPrefix
    resourceNameSuffix: resourceNameSuffix
    environmentNameTag: environmentNameTag
    applicationNameTag: applicationNameTag
    purposeDescriptionTag: 'Application Logging & Monitoring'
  }

  dependsOn: [
    logAnalytics
  ]
}
