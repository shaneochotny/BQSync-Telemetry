targetScope = 'resourceGroup'

param azureRegion string
param environmentPrefix string
param resourceNameSuffix string
param environmentNameTag string
param applicationNameTag string
param purposeDescriptionTag string

// Storage Account: Functions Storage
//    Bicep: https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts
resource appServiceStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: '${toLower(environmentPrefix)}${resourceNameSuffix}'
  location: azureRegion
  kind: 'StorageV2'

  sku: {
    name: 'Standard_LRS'
  }

  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    publicNetworkAccess: 'Enabled'
  }

  tags: {
    Environment: environmentNameTag
    Application: applicationNameTag
    Purpose: purposeDescriptionTag
  }
}

// Storage Account: Blob
//    Bicep: https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices/containers
resource storageAccountBlob 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: appServiceStorageAccount
}

// Storage Account: Container
//    Bicep: https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices/containers
resource storageAccountBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: 'functions'
  parent: storageAccountBlob
}
