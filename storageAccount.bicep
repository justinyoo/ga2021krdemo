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

output id string = st.id
output name string = st.name
