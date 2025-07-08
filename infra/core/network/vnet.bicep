@description('作成する VNet の名前')
param vnetName string

@description('リソースを配置するリージョン')
param location string = resourceGroup().location

@description('VNet のアドレス空間 (例: ["10.0.0.0/16"])')
param addressPrefixes array

@description('作成するサブネットの一覧。{ name: サブネット名, prefix: アドレスプレフィックス, nsgId: ネットワークセキュリティグループのリソース ID (空文字で未設定) } の配列')
param subnets array = [
  // 例:
  // {
  //   name: 'default'
  //   prefix: '10.0.0.0/24'
  //   nsgId: ''  // NSG を付けない場合は空文字
  // }
]

@description('タグ (任意)')
param tags object = {}

@description('仮想ネットワークを作成する')
resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      for sn in subnets: union(
        {
          name: sn.name
          properties: {
            addressPrefix: sn.prefix
          }
        },
        sn.nsgId != ''
          ? {
              properties: {
                networkSecurityGroup: {
                  id: sn.nsgId
                }
              }
            }
          : {}
      )
    ]
  }
}

// 出力 (app レイヤーで必要に応じて使えます)
output vnetId string = vnet.id
output vnetName string = vnet.name
output subnetIds array = [for sn in subnets: '${vnet.id}/subnets/${sn.name}']
