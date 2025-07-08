using './main.bicep'

@description('VNetの名前')
param vnetName = 'demoVnet'
@description('VNetのアドレスプレフィックス')
param vnetAddressPrefix = '10.121.0.0/16'
@description('Subnet1の名前')
param subnet1Name = 'demoSubnet1'
@description('Subnet1のアドレスプレフィックス')
param subnet1Prefix = '10.121.0.0/24'
@description('Subnet1のNSG名')
param subnet1NsgName = 'demo1'
@description('Subnet2の名前')
param subnet2Name = 'demoSubnet2'
@description('Subnet2のアドレスプレフィックス')
param subnet2Prefix = '10.121.1.0/24'
@description('Subnet2のNSG名')
param subnet2NsgName = 'demo2'

@description('Windows VMの名前')
param vmNameWindows = 'myWindowsVM'
@description('Windows VMのサイズ')
param vmSizeWindows = 'Standard_D2ads_v5'
@description('Windows VMの管理者ユーザー名')
param adminUsernameWindows = 'azureuser'
@description('Windows VMの管理者パスワード')
@secure()
param adminPasswordWindows = 'P@ssw0rd!'
@description('Windows VMのパブリックIPアドレス名')
param pipNameWindows = 'myWindowsVM'
@description('Windows VMのOSディスクのストレージアカウントタイプ')
param osDiskTypeWindows = 'StandardSSD_LRS'
@description('Windows VMのイメージリファレンス')
param imageOfferWindows = 'windows-11'
@description('Windows VMのイメージSKU')
param imageSkuWindows = 'win11-24h2-ent'

@description('Linux VMの名前')
param vmNameLinux  = 'myLinuxVM'
@description('Linux VMのサイズ')
param vmSizeLinux = 'Standard_B1s'
@description('Linux VMの管理者ユーザー名')
param adminUsernameLinux = 'azureuser'
@description('Linux VMの管理者パスワード')
@secure()
param adminPasswordLinux = 'P@ssw0rd!'
@description('Linux VMディスクのストレージアカウントタイプ')
param osDiskTypeLinux = 'StandardSSD_LRS'
@description('Linux VMのイメージリファレンスのオファー')
param imageOfferLinux = '0001-com-ubuntu-server-focal'
@description('Linux VMのイメージSKU')
param imageSkuLinux = '20_04-lts-gen2'

@description('tags for resources')
param tags = {
  createdBy: 'bicep'
  environment: 'demo'
}
