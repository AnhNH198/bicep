param keyVaultName string
param env string
param location string
param KVPolicies array
param appServiceName string
@secure()
param usrKey string
@secure()
param orgKey string
@secure()
param dbPassword string

var initialPolicies = [
  {
    tenantId: reference('Microsoft.Web/sites/${appServiceName}/providers/Microsoft.ManagedIdentity/Identities/default', '2018-11-30').tenantId
    objectId: reference('Microsoft.Web/sites/${appServiceName}/providers/Microsoft.ManagedIdentity/Identities/default', '2018-11-30').principalId
    permissions: {
        secrets: [
            'get'
        ]
    }
}
]

var policies = concat(initialPolicies, KVPolicies)

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  tags: {
    env: env
    createdBy: 'ARM Templates'
  }
  location: location
  properties: {
    enabledForDeployment: false
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    tenantId: subscription().tenantId
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    accessPolicies: policies
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource dbPass 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVaultName}/DB-PASSWORD'
  properties: {
      value: dbPassword
  }
  dependsOn: [
      keyVault
  ]
}

resource functionMasterKey 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVaultName}/USER-FUNCTION-MASTER-KEY'
  properties: {
      value: usrKey
  }
  dependsOn: [
      keyVault
  ]
}

resource orgFunctionMasterKey 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVaultName}/ORGANIZATION-FUNCTION-MASTER-KEY'
  properties: {
      value: orgKey
  }
  dependsOn: [
      keyVault
  ]
}
