param env string
param postgresDBName string
param location string
param postgresSku object
@secure()
param dbPassword string

resource postgreDB 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
  name: postgresDBName
  tags: {
    env : env
    createdBy: 'ARM Templates'
  }
  location: location
  sku: postgresSku
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    createMode: 'Default'
    version: '10'
    administratorLogin: 'postgres'
    administratorLoginPassword: dbPassword
    sslEnforcement: 'Enabled'
    minimalTlsVersion: 'TLSEnforcementDisabled'
    infrastructureEncryption: 'Disabled'
    publicNetworkAccess: 'Disabled'
    storageProfile: {
      storageMB: 10240
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
      storageAutogrow: 'Enabled'
  }
  }
}

output dbID string = postgreDB.id
