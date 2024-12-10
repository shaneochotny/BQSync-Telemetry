targetScope = 'resourceGroup'

param azureRegion string
param environmentPrefix string
param resourceNameSuffix string
param environmentNameTag string
param applicationNameTag string
param purposeDescriptionTag string

// Log Analytics: Workspace
//    Bicep: https://learn.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces
resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${toLower(environmentPrefix)}${resourceNameSuffix}'
  location: azureRegion

  properties: { 
    retentionInDays: 180
    sku: {
      name: 'PerGB2018'
    }
  }

  tags: {
    Environment: environmentNameTag
    Application: applicationNameTag
    Purpose: purposeDescriptionTag
  }
}
