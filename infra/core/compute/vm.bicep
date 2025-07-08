@description('作成する VM の名前')
param vmName string

@description('リソースを配置するリージョン')
param location string = resourceGroup().location

@description('VM サイズ')
param vmSize string = 'Standard_DS1_v2'

@description('OS タイプ ("Linux" または "Windows")')
@allowed([
  'Linux'
  'Windows'
])
param osType string = 'Linux'

@description('管理者ユーザー名')
param adminUsername string

@description('管理者パスワード (Windows/Linux 両対応)')
@secure()
param adminPassword string

@description('SSH 公開鍵 (Linux の場合にのみ使用)')
param sshPublicKey string = ''

@description('接続するサブネットのリソース ID')
param subnetId string

@description('パブリック IP を作成するか')
param createPublicIp bool = false

@description('パブリック IP 名 (createPublicIp = true 時に使用)')
param publicIpName string = 'pip-${vmName}'

@description('OS ディスクのストレージ アカウント タイプ')
@allowed(['Standard_LRS', 'Premium_LRS', 'StandardSSD_LRS', 'UltraSSD_LRS'])
param osDiskStorageAccountType string = 'Standard_LRS'

@description('追加データディスクの定義 (lun, sizeGB, storageAccountType) の配列')
param dataDisks array = [
  {lun: 0, sizeGB: 128, storageAccountType: 'Standard_LRS'}
]

@description('OS イメージの参照')
param imageReference object = osType == 'Windows'
  ? {
      publisher: 'MicrosoftWindowsDesktop'
      offer: 'windows-11'
      sku: 'win11-24h2-ent'
      version: 'latest'
    }
  : {
      publisher: 'Canonical'
      offer: '0001-com-ubuntu-server-focal'
      sku: '20_04-lts-gen2'
      version: 'latest'
    }

@description('全リソースに付与するタグ')
param tags object = {}

@description('パブリックIPを作成する(オプション)')
resource pip 'Microsoft.Network/publicIPAddresses@2024-07-01' = if (createPublicIp) {
  name: publicIpName
  location: location
  sku: { name: 'Basic' }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

@description('仮想マシンに接続するネットワークインターフェース')
resource nic 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: 'nic-${vmName}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      union(
        {
          name: 'ipconfig'
          properties: {
            subnet: { id: subnetId }
            primary: true
          }
        },
        createPublicIp ? { properties: { publicIPAddress: { id: pip.id } } } : {}
      )
    ]
  }
}

@description('仮想マシンのリソース')
resource vm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: { vmSize: vmSize }
    osProfile: osType == 'Windows'
      ? {
          computerName: vmName
          adminUsername: adminUsername
          adminPassword: adminPassword
          windowsConfiguration: { enableAutomaticUpdates: true }
        }
      : {
          computerName: vmName
          adminUsername: adminUsername
          adminPassword: adminPassword ?? null
          linuxConfiguration: {
            disablePasswordAuthentication: sshPublicKey != ''
            ssh: sshPublicKey != ''
              ? {
                  publicKeys: [
                    {
                      path: '/home/${adminUsername}/.ssh/authorized_keys'
                      keyData: sshPublicKey
                    }
                  ]
                }
              : null
          }
        }
    networkProfile: {
      networkInterfaces: [{ id: nic.id, properties: { primary: true } }]
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        createOption: 'FromImage'
        managedDisk: { storageAccountType: osDiskStorageAccountType }
      }
      dataDisks: [
        for disk in dataDisks: {
          lun: disk.lun
          createOption: 'Empty'
          diskSizeGB: disk.sizeGB
          managedDisk: { storageAccountType: disk.storageAccountType }
        }
      ]
    }
  }
}

// 出力
output vmId string = vm.id
output nicId string = nic.id
output publicIpId string = createPublicIp ? pip.id : ''
output osTypeOutput string = osType
output osDiskType string = osDiskStorageAccountType
output dataDisksInfo array = dataDisks
