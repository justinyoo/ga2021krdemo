param name string
param location string = resourceGroup().location
param locationCode string = 'krc'

param storageSku string = 'Standard_LRS'

var metadata = {
  longName: '{0}-${name}-${locationCode}'
  shortName: '{0}${name}${locationCode}'
}

// Storage Account
var storage = {
  name: format(metadata.shortName, 'st')
  location: location
  sku: storageSku
}

resource st 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storage.name
  location: storage.location
  kind: 'StorageV2'
  sku: {
    name: storage.sku
  }
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

// Consumption Plan
var consumption = {
  name: format(metadata.longName, 'csplan')
  location: location
}

resource csplan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: consumption.name
  location: consumption.location
  kind: 'functionApp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

// Azure Function
var functionApp = {
  name: format(metadata.longName, 'fncapp')
  location: location
}

resource fncapp 'Microsoft.Web/sites@2020-12-01' = {
  name: functionApp.name
  location: functionApp.location
  kind: 'functionapp'
  properties: {
    serverFarmId: csplan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${st.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(st.id, '2021-02-01').keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTION_APP_EDIT_MODE'
          value: 'readonly'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${st.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(st.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionApp.name
        }
      ]
    }
  }
}
