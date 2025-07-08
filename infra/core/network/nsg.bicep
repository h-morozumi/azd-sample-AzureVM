@description('作成する NSG の名前')
param nsgName string

@description('リソースを配置するリージョン')
param location string = resourceGroup().location

@description('NSG に設定するセキュリティルールの一覧')
param securityRules array = [
  /*
    例:
    {
      name: 'Allow-HTTP',
      priority: 100,
      direction: 'Inbound',      // 'Inbound' or 'Outbound'
      access: 'Allow',           // 'Allow' or 'Deny'
      protocol: 'Tcp',           // 'Tcp', 'Udp', '*' のいずれか
      sourcePortRange: '*',
      destinationPortRange: '80',
      sourceAddressPrefix: '*',
      destinationAddressPrefix: '*',
      description: 'Allow HTTP'
    }
  */
]

@description('タグ (任意)')
param tags object = {}

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      for rule in securityRules: {
        name: rule.name
        properties: {
          priority: rule.priority
          direction: rule.direction
          access: rule.access
          protocol: rule.protocol
          sourcePortRange: rule.sourcePortRange
          destinationPortRange: rule.destinationPortRange
          sourceAddressPrefix: rule.sourceAddressPrefix
          destinationAddressPrefix: rule.destinationAddressPrefix
          description: rule.description
        }
      }
    ]
  }
}

output nsgId string = nsg.id
output nsgNameOutput string = nsg.name
