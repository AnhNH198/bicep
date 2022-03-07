param env string
param location string
param virtualNetID string
param appServiceName string
param appServicePlanID string
param storageAccountName string
param appServiceProperties object
@secure()
param usrFunctionMasterKeyValue string
@secure()
param orgFunctionMasterKeyValue string
@secure()
param DBPassword string

var storageId = resourceId('Microsoft.Storage/storageAccounts', storageAccountName)

resource appServiceApp 'Microsoft.Web/sites@2020-06-01' = {
  name: appServiceName
  location: location
  tags: {
    env: env
    createdBy: 'ARM Templates'
  }
  kind: 'app,linux'
  identity: {
    type:'SystemAssigned'
  }
  properties: {
    siteConfig:{
      appSettings:[
        {
          name: 'DJANGO_SETTING_MODULE'
          value: 'local_settings'
        }
        {
          name: 'FUNCTION_MASTER_KEY'
          value: usrFunctionMasterKeyValue
        }
        {
          name: 'REACT_APP_FUNCTION_MASTER_KEY'
          value: usrFunctionMasterKeyValue
        }
        {
          name: 'ORGANIZATION_FUNCTION_MASTER_KEY'
          value: orgFunctionMasterKeyValue
        }
        {
          name: 'DB-PASSWORD'
          value: DBPassword
        }
      ]
    }
    enabled: true
    reserved: true
    isXenon: false
    hyperV: false
    serverFarmId: appServicePlanID
    httpsOnly: true
  }
}

resource appServiceConfig 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '${appServiceApp.name}/web'
  properties: appServiceProperties
}

resource storageSetting 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${appServiceApp.name}/azurestorageaccounts'
  properties: {
    'config': {
      type: 'AzureBlob'
      shareName: '-web-config'
      mountPath: '/home/configg'
      accountName: storageAccountName      
      accessKey: '${listKeys(storageId, '2019-06-01').keys[0].value}'
    }
  }
}

resource vnetConnect 'Microsoft.Web/sites/virtualNetworkConnections@2021-02-01' = {
  name: concat('${appServiceName}/virtualNetworkConnection')
  dependsOn: [
    appServiceApp
  ]
  properties: {
    vnetResourceId: '${virtualNetID}/subnets/appService'
    isSwift: true
  }
}
