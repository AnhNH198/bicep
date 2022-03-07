param postgresDBName string
param vnetID string

resource privateDNS 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.postgres.database.azure.com'
  location: 'global'  
  properties: {
    maxNumberOfRecordSets: 25000
    maxNumberOfVirtualNetworkLinks: 1000
    maxNumberOfVirtualNetworkLinksWithRegistration: 100
    numberOfRecordSets: 2
    numberOfVirtualNetworkLinks: 1
    numberOfVirtualNetworkLinksWithRegistration: 0
    provisioningState: 'Succeeded'
  }
}

resource privateDNSZoneA 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  name: 'privatelink.postgres.database.azure.com/${postgresDBName}'
  properties: {
    ttl: 10
    aRecords: [
      {
        ipv4Address: '10.0.1.4'
      }
    ]
  }
  dependsOn: [
    privateDNS
  ]
}

resource privateDNSZoneS0A 'Microsoft.Network/privateDnsZones/SOA@2018-09-01' = {
  name: 'privatelink.postgres.database.azure.com/@'
  properties: {
    ttl: 3600
    soaRecord: {
        email: 'azureprivatedns-host.microsoft.com'
        expireTime: 2419200
        host: 'azureprivatedns.net'
        minimumTtl: 10
        refreshTime: 3600
        retryTime: 300
        serialNumber: 1
    }
  }
  dependsOn: [
    privateDNS
  ]
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  name: '${privateDNS.name}/xgxhnuawssacu'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetID
    }
  }
}

output dnsZoneID string = privateDNS.id
