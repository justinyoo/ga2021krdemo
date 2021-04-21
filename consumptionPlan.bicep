param name string
param location string = resourceGroup().location
param locationCode string = 'krc'

var metadata = {
  longName: '{0}-${name}-${locationCode}'
  shortName: '{0}${name}${locationCode}'
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

output id string = csplan.id
output name string = csplan.name
