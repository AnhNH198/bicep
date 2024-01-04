param virtualMachines_testvm_name string = 'testvm'
param networkInterfaces_testvm_nic_name string = 'testvm-nic'
param virtualNetworks_vm_externalid string = '/subscriptions/72a3f9e6-ddb2-4621-91ef-b5dd758420d1/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/vm'

resource networkInterfaces_testvm_nic_name_resource 'Microsoft.Network/networkInterfaces@2023-06-01' = {
  name: networkInterfaces_testvm_nic_name
  location: 'eastus'
  tags: {
    source: 'terraform'
  }
  kind: 'Regular'
  properties: {
    ipConfigurations: [
      {
        name: '${networkInterfaces_testvm_nic_name}0'
        id: '${networkInterfaces_testvm_nic_name_resource.id}/ipConfigurations/${networkInterfaces_testvm_nic_name}0'
        etag: 'W/"86f78617-1292-45a6-9995-1bc5c90114cd"'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          provisioningState: 'Succeeded'
          privateIPAddress: '172.16.1.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: '${virtualNetworks_vm_externalid}/subnets/vm'
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    disableTcpStateTracking: false
    nicType: 'Standard'
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
  }
}

resource virtualMachines_testvm_name_resource 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: virtualMachines_testvm_name
  location: 'eastus'
  tags: {
    source: 'terraform'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${virtualMachines_testvm_name}_disk1_1ff72c89f8694a60a71c8a537429d665'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        writeAcceleratorEnabled: false
        managedDisk: {
          storageAccountType: 'Standard_LRS'
          id: resourceId('Microsoft.Compute/disks', '${virtualMachines_testvm_name}_disk1_1ff72c89f8694a60a71c8a537429d665')
        }
        deleteOption: 'Detach'
        diskSizeGB: 30
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_testvm_name
      adminUsername: 'azureuser'
      linuxConfiguration: {
        disablePasswordAuthentication: false
        ssh: {
          publicKeys: []
        }
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
        enableVMAgentPlatformUpdates: false
      }
      secrets: []
      allowExtensionOperations: false
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_testvm_nic_name_resource.id
          properties: {
            primary: true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
    priority: 'Regular'
    extensionsTimeBudget: 'PT1H30M'
  }
}
