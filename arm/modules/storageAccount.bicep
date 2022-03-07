param env string
param storageAccountName string
param location string
param storageAccountSkuName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  tags: {
    env : env
    createdBy: 'ARM Templates'
  }
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
  }
  properties: {
    accessTier: 'Hot'
  }
}

resource blob_storage 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  name: '${storageAccount.name}/default'
}

resource container_web_config 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${storageAccount.name}/default/-web-config'
  dependsOn: [
    storageAccount
    blob_storage
  ]
}

resource container_web_media 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${storageAccount.name}/default/-web-media'
  dependsOn: [
    storageAccount
    blob_storage
  ]
}

resource container_web_login_site 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  name: '${storageAccount.name}/default/-web-login'
  dependsOn: [
    storageAccount
    blob_storage
  ]
}

output accountName string = storageAccount.name
