targetScope = 'resourceGroup'

param azureRegion string
param environmentPrefix string
param resourceNameSuffix string
param environmentNameTag string
param applicationNameTag string
param purposeDescriptionTag string

// Reference: Log Analyitics
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: '${toLower(environmentPrefix)}${resourceNameSuffix}'
}

// Azure Event Hub Namespace
//   Bicep: https://docs.microsoft.com/en-us/azure/templates/microsoft.eventhub/namespaces
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-05-01-preview' = {
  name: '${toLower(environmentPrefix)}${resourceNameSuffix}'
  location: azureRegion

  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    capacity: 1
    name: 'Standard'
  }
  properties: {
    kafkaEnabled: true
    minimumTlsVersion: '1.2'
  }

  tags: {
    Environment: environmentNameTag
    Application: applicationNameTag
    Purpose: purposeDescriptionTag
  }
}

// Azure Event Hub / Topic:
//   Bicep: https://docs.microsoft.com/en-us/azure/templates/microsoft.eventhub/namespaces/eventhubs
resource telemetryEventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-05-01-preview' = {
  name: 'telemetry'
  parent: eventHubNamespace

  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
  }
}

// Azure Event Hub Consumer Group: Consumer Group for the consuming client
//   Bicep: https://docs.microsoft.com/en-us/azure/templates/microsoft.eventhub/namespaces/eventhubs/consumergroups
resource telemetryEventHubConsumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2024-05-01-preview' = {
  name: 'TelemetryConsumer'
  parent: telemetryEventHub
}

// Azure Event Hub / Topic: Policy to allow API to send
//   Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.eventhub/namespaces/eventhubs/authorizationrules
resource telemetryEventHubPolicy 'Microsoft.EventHub/namespaces/eventhubs/authorizationRules@2022-10-01-preview' = {
  name: 'api'
  parent: telemetryEventHub
  properties: {
    rights: [
      'send'
    ]
  }
}

// Diagnostic Logs for Azure Functions
//     Bicep: https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings
resource eventHubNamespaceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'Diagnostics'
  scope: eventHubNamespace

  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
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
