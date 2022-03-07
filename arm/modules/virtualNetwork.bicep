param vnetName string
param location string
param env string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vnetName
  tags: {
    env: env
    createdBy: 'ARM Templates'
  }
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'privateEndpoint'
        properties: {
          addressPrefix: '10.0.1.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Sql'
              locations: [
                '*'
              ]
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'appService'
        properties: {
          addressPrefix: '10.0.2.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Web'
              locations: [
                '*'
              ]
            }
          ]
          delegations: [
            {
              name: 'delegation'
              properties: {
                'serviceName': 'Microsoft.Web/serverfarms'
              }
            }
          ]
          privateLinkServiceNetworkPolicies: 'Enabled'
          privateEndpointNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

output vnetID string = virtualNetwork.id
