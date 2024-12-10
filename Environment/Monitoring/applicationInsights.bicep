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

// Application Insights
//    Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/components
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${toLower(environmentPrefix)}${resourceNameSuffix}'
  location: azureRegion
  kind: 'web'

  properties: { 
    Application_Type: 'web'
    Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    WorkspaceResourceId: logAnalytics.id
  }

  tags: {
    Environment: environmentNameTag
    Application: applicationNameTag
    Purpose: purposeDescriptionTag
  }
}
