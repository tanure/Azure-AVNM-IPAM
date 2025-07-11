import { _environment, _regions } from './types.bicep'

param location string = resourceGroup().location

param ipam _environment = {
  avnm: {
    name: 'avnm01'
    subscriptioNScopes: [subscription().id]
    managementGroupScopes: []
  }
  settings: {
    rootIPAMpoolName: 'AzureGlobal'
    AzureCIDR: '172.16.0.0/12'
    RegionCIDRsize: 16
    RegionCIDRsplitSize: 24
  }
}

param regions _regions = [
  {
    name: 'northeurope'
    displayName: 'North Europe'
    PlatformAndApplicationSplitFactor: 10
    ConnectivityAndIdentitySplitFactor: 50
    CorpAndOnlineSplitFactor: 75
    cidr: cidrSubnet(ipam.settings.AzureCIDR, ipam.settings.RegionCIDRsize, 0)
  }
  {
    name: 'westeurope'
    displayName: 'West Europe'
    PlatformAndApplicationSplitFactor: 10
    ConnectivityAndIdentitySplitFactor: 50
    CorpAndOnlineSplitFactor: 75
    cidr: cidrSubnet(ipam.settings.AzureCIDR, ipam.settings.RegionCIDRsize, 1)
  }
]

resource avnm 'Microsoft.Network/networkManagers@2024-07-01' = {
  name: ipam.avnm.name
  location: location
  properties: {
    networkManagerScopes: {
      managementGroups: ipam.avnm.?managementGroupScopes
      subscriptions: ipam.avnm.?subscriptioNScopes
    }
  }
}

resource rootIPAMpool 'Microsoft.Network/networkManagers/ipamPools@2024-07-01' = {
  name: replace(ipam.settings.AzureCIDR, '/', '-')
  parent: avnm
  location: location
  properties: {
    addressPrefixes: [
      ipam.settings.AzureCIDR
    ]
    displayName: ipam.settings.rootIPAMpoolName
    description: 'Root IPAM pool for Azure CIDR block (${ipam.settings.AzureCIDR})'
  }
}

module ipamPerRegion 'ipamPerRegion.bicep' = [
  for region in regions: {
    name: 'ipamPerRegion-${region.name}'
    params: {
      regionDisplayName: region.displayName
      regionCIDR: region.cidr
      location: region.name
      rootIPAMpoolName: rootIPAMpool.name
      avnmName: avnm.name
      RegionCIDRsplitSize: ipam.settings.RegionCIDRsplitSize
      PlatformAndApplicationSplitFactor: region.PlatformAndApplicationSplitFactor
      ConnectivityAndIdentitySplitFactor: region.ConnectivityAndIdentitySplitFactor
      CorpAndOnlineSplitFactor: region.CorpAndOnlineSplitFactor
    }
  }
]
