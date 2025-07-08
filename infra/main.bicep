@description('リソースを配置するリージョン')
param location string = resourceGroup().location

@description('VNetの名前')
param vnetName string
@description('VNetのアドレスプレフィックス')
param vnetAddressPrefix string 
@description('サブネット1の設定')
param subnet1Name string 
@description('サブネット1のアドレスプレフィックス')
param subnet1Prefix string
@description('サブネット1のNSG名')
param subnet1NsgName string
@description('サブネット2の設定')
param subnet2Name string 
@description('サブネット2のアドレスプレフィックス')
param subnet2Prefix string
@description('サブネット2のNSG名')
param subnet2NsgName string

@description('タグ (任意)')
param tags object = {}

var abbrs = loadJsonContent('./abbreviations.json')
var suffix = uniqueString(resourceGroup().id)

@description('VNetの設定')
var demoVnet = {
  vnetName: vnetName
  addressPrefixes: [vnetAddressPrefix]
  subnets: [
    { name: subnet1Name, prefix: subnet1Prefix, nsgName: subnet1NsgName }
    { name: subnet2Name, prefix: subnet2Prefix, nsgName: subnet2NsgName }
  ]
}

@description('Windows VMの名前')
param vmNameWindows string
@description('Windows VMのサイズ')
param vmSizeWindows string
@description('Windows VMの管理者ユーザー名')
param adminUsernameWindows string
@description('Windows VMの管理者パスワード')
@secure()
param adminPasswordWindows string
@description('Windows VMのパブリックIPアドレス名')
param pipNameWindows string
@description('Windows VMのOSディスクのストレージアカウントタイプ')
param osDiskTypeWindows string
@description('Windows VMのイメージリファレンス')
param imageOfferWindows string
@description('Windows VMのイメージSKU')
param imageSkuWindows string

@description('Windows VMの設定')
var windowsVM = {
  vmName: vmNameWindows
  vmSize: vmSizeWindows
  osType: 'Windows'
  adminUsername: adminUsernameWindows
  adminPassword: adminPasswordWindows
  createPublicIp: true
  publicIpName: '${abbrs.networkPublicIPAddresses}${pipNameWindows}'
  osDiskStorageAccountType: osDiskTypeWindows
  dataDisks: []
  imageReference: {
    publisher: 'MicrosoftWindowsDesktop'
    offer: imageOfferWindows
    sku: imageSkuWindows
    version: 'latest'
  }
}

@description('Linux VMの名前')
param vmNameLinux string
@description('Linux VMのサイズ')
param vmSizeLinux string
@description('Linux VMの管理者ユーザー名')
param adminUsernameLinux string
@description('Linux VMの管理者パスワード')
@secure()
param adminPasswordLinux string
@description('Linux VMディスクのストレージアカウントタイプ')
param osDiskTypeLinux string
@description('Linux VMのイメージリファレンスのオファー')
param imageOfferLinux string
@description('Linux VMのイメージSKU')
param imageSkuLinux string

@description('Linux VMの設定')
var linuxVM = {
  vmName: vmNameLinux
  vmSize: vmSizeLinux
  osType: 'Linux'
  adminUsername: adminUsernameLinux
  adminPassword: adminPasswordLinux
  createPublicIp: false
  osDiskStorageAccountType: osDiskTypeLinux
  dataDisks: [
    { lun: 0, sizeGB: 100, storageAccountType: osDiskTypeLinux }
  ]
  imageReference: {
    publisher: 'Canonical'
    offer: imageOfferLinux
    sku: imageSkuLinux
    version: 'latest'
  }
}

@description('Subnetのパラメータにプレフィックスを追加')
var enrichedSubnets = [
  for sn in demoVnet.subnets: union(
    {
      name: '${abbrs.networkVirtualNetworksSubnets}${sn.name}'
      prefix: sn.prefix
    },
    // sn.nsgName が空文字でなければ { nsgId: sn.nsgName } をマージ、空文字なら {} をマージ
    sn.nsgName != '' ? {
      nsgName: '${abbrs.networkNetworkSecurityGroups}${sn.nsgName}'
    } : {
      nsgName: ''
    }
  )
]

@description('DEMO環境を作成するモジュール')
module demo 'app/sample.bicep' = {
  name: 'mk-demo'
  params: {
    vnetName: '${abbrs.networkVirtualNetworks}${demoVnet.vnetName}-${suffix}'
    location: location
    addressPrefixes: demoVnet.addressPrefixes
    subnets: enrichedSubnets
    tags: tags
    windowsVM: windowsVM
    linuxVM: linuxVM
  }
}
