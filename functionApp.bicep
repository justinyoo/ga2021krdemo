param name string
param location string = resourceGroup().location
param locationCode string = 'krc'

param storageAccountId string
param stroageAccountName string
param consumptionPlanId string

var metadata = {
  longName: '{0}-${name}-${locationCode}'
  shortName: '{0}${name}${locationCode}'
}

// Azure Function
var functionApp = {
  name: format(metadata.longName, 'fncapp')
  location: location
  storageAccount: {
    id: storageAccountId
    name: stroageAccountName
  }
  consumptionPlan: {
    id: consumptionPlanId
  }
}

resource fncapp 'Microsoft.Web/sites@2020-12-01' = {
  name: functionApp.name
  location: functionApp.location
  kind: 'functionapp'
  properties: {
    serverFarmId: functionApp.consumptionPlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionApp.storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(functionApp.storageAccount.id, '2021-02-01').keys[0].value}'
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
          value: 'DefaultEndpointsProtocol=https;AccountName=${functionApp.storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(functionApp.storageAccount.id, '2019-06-01').keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionApp.name
        }
      ]
    }
  }
}

output id string = fncapp.id
output name string = fncapp.name
