targetScope = 'resourceGroup'

param azureRegion string
param environmentPrefix string
param resourceNameSuffix string
param environmentNameTag string
param applicationNameTag string
param purposeDescriptionTag string
param deployEventHubs bool
param eventHubConnectionString string

// Storage Blob Data Owner Role
var storageRoleDefinitionId  = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'

// Reference: Storage Account
resource appServiceStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: '${toLower(environmentPrefix)}${resourceNameSuffix}'
}

// Reference: Event Hubs
resource telemetryEventHubPolicy 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2024-05-01-preview' existing = {
  name: '${toLower(environmentPrefix)}${resourceNameSuffix}/telemetry/api'
}

// Reference: Log Analyitics
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: '${toLower(environmentPrefix)}${resourceNameSuffix}'
}

// Reference: Application Insights
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: '${toLower(environmentPrefix)}${resourceNameSuffix}'
}

// App Service: Plan
//    Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms
resource appServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: '${toLower(environmentPrefix)}${resourceNameSuffix}'
  location: azureRegion
  kind: 'functionapp'

  sku: {
    tier: 'FlexConsumption'
    name: 'FC1'
  }

  properties: {
    reserved: true
  }

  tags: {
    Environment: environmentNameTag
    Application: applicationNameTag
    Purpose: purposeDescriptionTag
  }
}

// App Service: Function App
//    Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.web/sites
resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: '${toLower(environmentPrefix)}${resourceNameSuffix}'
  location: azureRegion
  kind: 'functionapp,linux'

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage__accountName'
          value: appServiceStorageAccount.name
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsights.properties.ConnectionString
        }
        {
          name: 'EventHubConnectionString'
          value: (deployEventHubs) ? '${telemetryEventHubPolicy.listKeys().primaryConnectionString}' : eventHubConnectionString
        }
      ]
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${appServiceStorageAccount.properties.primaryEndpoints.blob}functions'
          authentication: {
            type: 'SystemAssignedIdentity'
          }
        }
      }
      scaleAndConcurrency: {
        maximumInstanceCount: 100
        instanceMemoryMB: 2048
      }
      runtime: { 
        name: 'dotnet-isolated'
        version: '9.0'
      }
    }
  }

  tags: {
    Environment: environmentNameTag
    Application: applicationNameTag
    Purpose: purposeDescriptionTag
  }
}

// Role Assignment: Functions MSI Storage Blob Data Owner
//     Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appServiceStorageAccount.id, storageRoleDefinitionId)
  scope: appServiceStorageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageRoleDefinitionId)
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Diagnostic Logs for Azure Functions
//     Bicep: https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings
resource functionAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Diagnostics'
  scope: functionApp

  properties: {
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    workspaceId: logAnalytics.id
  }
}
