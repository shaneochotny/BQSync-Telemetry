using './main.bicep'

@allowed([
  'PRD'
  'DEV'
])
@description('Development or Production environment resource prefixes.')
param environmentPrefix = 'PRD'

@description('Suffix used on all Resource names for uniqueness.')
@minLength(3)
@maxLength(3)
param resourceNameSuffix = 'bqsynctelemetry'

@description('Resource Group name for all resources.')
param resourceGroupName = 'BQSync-Telemetry'

@allowed([
  'Production'
  'Development'
])
@description('Development or Production environment names for use in Resource Tags.')
param environmentNameTag = 'Production'

@description('Name of the solution/application for use in Resource Tags.')
param applicationNameTag = 'BQSync Telemetry'

@description('Description of the solution/application for use in Resource Tags.')
param purposeDescriptionTag = 'APIs for BQSync Telemetry'

@description('Primary region to create all the resources in.')
param azureRegion = 'eastus2'

@description('Deploy an Azure Event Hub or manually specify the eventHubConnectionString.')
param deployEventHubs = true

@description('Connection string for Azure Event Hubs for Fabric Eventstream if deployEventHubs = false.')
param eventHubConnectionString = ''
