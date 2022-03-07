param prvLinkName string
param location string
param env string
param postgresDBID string
param virtualNetID string
param dbHost string
param prvDNSZoneID string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: prvLinkName
  location: location
  tags: {
    env : env
    createdBy: 'ARM Templates'
  }
  properties: {
    privateLinkServiceConnections: [
      {
        name: prvLinkName
        properties: {
          privateLinkServiceId: postgresDBID
          groupIds: [
            'postgresqlServer'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: '${virtualNetID}/subnets/privateEndpoint'
    }
    customDnsConfigs: [
      {
        fqdn: dbHost
        ipAddresses: [
          '10.0.1.4'
        ]
      }
    ]
  }
}

resource privateDNS 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-03-01' = {
  name: '${prvLinkName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-postgres-database-azure-com'
        properties: {
          privateDnsZoneId: prvDNSZoneID
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}
