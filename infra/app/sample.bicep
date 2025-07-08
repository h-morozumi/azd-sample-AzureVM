@description('リソースを配置するリージョン')
param location string = resourceGroup().location

@description('作成する VNet の名前')
param vnetName string
@description('VNet のアドレス空間 (例: ["10.0.0.0/16"])')
param addressPrefixes array
@description('作成するサブネットの一覧。{ name: サブネット名, prefix: アドレスプレフィックス } の配列')
param subnets array = []
@description('タグ (任意)')
param tags object = {}

@description('Windows VMの設定')
param windowsVM object
@description('Linux VMの設定')
param linuxVM object

@description('Subnet1用のNSGを作成するモジュール')
module subnet1Nsg '../core/network/nsg.bicep' = {
  name: 'subnet1-nsg'
  params: {
    nsgName: subnets[0].nsgName
    securityRules: [
      {
        name: 'Allow-HTTP'
        priority: 100
        direction: 'Inbound'
        access: 'Allow'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '80'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        description: 'Allow HTTP from anywhere'
      }
      {
        name: 'Deny-All-Outbound'
        priority: 4096
        direction: 'Outbound'
        access: 'Deny'
        protocol: '*'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        description: 'Deny all outbound traffic'
      }
    ]
    tags: union(tags, {
      environment: 'prod'
      owner: 'infra-team'
    })
  }
}

@description('Subnet2用のNSGを作成するモジュール')
module subnet2Nsg '../core/network/nsg.bicep' = {
  name: 'subnet2-nsg'
  params: {
    nsgName: subnets[1].nsgName
    securityRules: []
    tags: union(tags, {
      environment: 'prod'
      owner: 'infra-team'
    })
  }
}

@description('元の subnets パラメーターに nsgId を付加した新しい配列を作成')
var enrichedSubnets = [
  for sn in subnets: union(
    {
      name: sn.name
      prefix: sn.prefix
    },
    // sn.nsgName が空文字でなければ { nsgId: sn.nsgName } をマージ、空文字なら {} をマージ
    sn.nsgName != ''
      ? {
          nsgId: resourceId('Microsoft.Network/networkSecurityGroups', sn.nsgName)
        }
      : {
          nsgId: ''
        }
  )
]

@description('VNetを作成するモジュール')
module vnet '../core/network/vnet.bicep' = {
  name: 'mk-vnet'
  params: {
    vnetName: vnetName
    location: location
    addressPrefixes: addressPrefixes
    subnets: enrichedSubnets
    tags: tags
  }
  dependsOn: [
    subnet1Nsg
    subnet2Nsg
  ]
}

@description('Linux VMを作成するモジュール')
module vmLinux '../core/compute/vm.bicep' = {
  name: 'vm-Linux'
  params: {
    vmName: linuxVM.vmName
    vmSize: linuxVM.vmSize
    osType: linuxVM.osType
    adminUsername: linuxVM.adminUsername
    adminPassword: linuxVM.adminPassword
    subnetId: vnet.outputs.subnetIds[0]
    createPublicIp: linuxVM.createPublicIp
    osDiskStorageAccountType: linuxVM.osDiskStorageAccountType
    dataDisks: linuxVM.dataDisks
    imageReference: linuxVM.imageReference
    tags: union(tags, {
      environment: 'prod'
      owner: 'app-team'
    })
  }
}

@description('Windows VMを作成するモジュール')
module vmWindows '../core/compute/vm.bicep' = {
  name: 'create-vm-Windows'
  params: {
    vmName: windowsVM.vmName
    vmSize: windowsVM.vmSize
    osType: windowsVM.osType
    adminUsername: windowsVM.adminUsername
    adminPassword: windowsVM.adminPassword
    subnetId: vnet.outputs.subnetIds[1]
    createPublicIp: windowsVM.createPublicIp
    publicIpName: windowsVM.publicIpName
    osDiskStorageAccountType: windowsVM.osDiskStorageAccountType
    dataDisks: windowsVM.dataDisks
    imageReference: windowsVM.imageReference
    tags: union(tags, {
      environment: 'prod'
      owner: 'app-team'
    })
  }
}
