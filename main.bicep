param name string
param location string = resourceGroup().location

module st './storageAccount.bicep' = {
  name: 'StorageAccountProvisioning'
  params: {
    name: name
    location: location
  }
}

module csplan './consumptionPlan.bicep' = {
  name: 'ConsumptionPlanProvisioning'
  params: {
    name: name
    location: location
  }
}

module fncapp './functionApp.bicep' = {
  name: 'FunctionAppProvisioning'
  params: {
    name: name
    location: location
    storageAccountId: st.outputs.id
    stroageAccountName: st.outputs.name
    consumptionPlanId: csplan.outputs.id
  }
}
