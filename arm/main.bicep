param env string
param location string
param kvCommonRG string
param storageAccountSkuName string
param appServicePlanSku object
param appServicePlanProperties object
param appServiceProperties object
param postgresSku object
param KVPolicies array
@secure()
param dbPassword string

var postgresDBName = 'db-web-${env}-we-01'
var appServicePlanName = 'plan-web-${env}-we-01'
var appServiceName = 'web-web-${env}-we-01'
var storageAccountName = 'straweb${env}we01'
var keyVaultName = 'kv-web-${env}-we-01'
var kvCommonName = 'kv-${env}-common-we'
var translatorUsrName = 'func-core-user-${env}-we'
var translatorOrgName = 'func-core-organization-${env}-we'
var vnetName = 'vnet-web-${env}-we-01'
var prvLinkName = 'pl-web-${env}-we-01'
var dbHost = '${postgresDBName}.postgres.database.azure.com'
var keyVaultSecretsUri = 'https://${keyVaultName}.vault.azure.net/secrets'
var usrFunctionMasterKeyValue = '@Microsoft.KeyVault(SecretUri=${keyVaultSecretsUri}/USER-FUNCTION-MASTER-KEY)'
var orgFunctionMasterKeyValue = '@Microsoft.KeyVault(SecretUri=${keyVaultSecretsUri}/ORGANIZATION-FUNCTION-MASTER-KEY)'
var DBPassword = '@Microsoft.KeyVault(SecretUri=${keyVaultSecretsUri}/DB-PASSWORD)'

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    env: env
    location: location
    storageAccountName: storageAccountName
    storageAccountSkuName: storageAccountSkuName
  }
}
module postgresDB 'modules/postgresDB.bicep' = {
  name: 'postgreDatabase'
  params: {
    env: env
    location: location
    dbPassword: dbPassword
    postgresSku: postgresSku
    postgresDBName: postgresDBName
}
}
module virNet 'modules/virtualNetwork.bicep' = {
  name: 'VirtualNetwork'
  params: {
    env: env
    location: location 
    vnetName: vnetName
  }
  dependsOn: [
    postgresDB
  ]
}
module appServicePlan 'modules/appServicePlan.bicep' = {
  name: 'appServicePlan'
  params: {
    env: env
    location: location
    appServicePlanSKU: appServicePlanSku
    appServicePlanName: appServicePlanName
    appServicePlanProperties: appServicePlanProperties
  }
}
module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    env: env
    location: location
    appServiceName: appServiceName
    virtualNetID: virNet.outputs.vnetID
    storageAccountName: storageAccountName
    appServiceProperties: appServiceProperties
    appServicePlanID: appServicePlan.outputs.id
    usrFunctionMasterKeyValue: usrFunctionMasterKeyValue
    orgFunctionMasterKeyValue: orgFunctionMasterKeyValue
    DBPassword: DBPassword
  }
  dependsOn: [
    appServicePlan
    storageAccount
    virNet
  ]
}

resource kvCommon 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: kvCommonName
  scope: resourceGroup(kvCommonRG)
}

module keyvault 'modules/keyVault.bicep' = {
  name: 'keyvault'
  params: {
    env: env
    location: location
    usrKey: kvCommon.getSecret('users-master-key')
    orgKey: kvCommon.getSecret('organizations-master-key')
    KVPolicies: KVPolicies
    dbPassword: dbPassword
    keyVaultName: keyVaultName
    appServiceName: appServiceName
  }
  dependsOn: [
    appService
    postgresDB
  ]
}
module dnsPrivateZone 'modules/privateDNS.bicep' = {
  name: 'privateDNSZone'
  params: {
    postgresDBName: postgresDBName
    vnetID: virNet.outputs.vnetID
  }
  dependsOn: [
    virNet
  ]
}
module privateEndpoint 'modules/privateEndpoint.bicep' = {
  name: 'PrivateEndPoint'
  params: {
    env: env
    dbHost: dbHost
    location: location
    virtualNetID: virNet.outputs.vnetID
    prvLinkName: prvLinkName
    postgresDBID: postgresDB.outputs.dbID
    prvDNSZoneID: dnsPrivateZone.outputs.dnsZoneID
  }
  dependsOn: [
    virNet
    postgresDB
    appService
    dnsPrivateZone
  ]
}
