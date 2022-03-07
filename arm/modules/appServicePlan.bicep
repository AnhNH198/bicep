param env string
param appServicePlanSKU object
param appServicePlanProperties object
param location string
param appServicePlanName string

resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
    name: appServicePlanName
    tags: {
      env : env
      createdBy: 'ARM Templates'
    }
    kind: 'linux'
    location: location
    sku: appServicePlanSKU
    properties: appServicePlanProperties
  }

  output name string = appServicePlan.name
  output id string = appServicePlan.id
