param location string = resourceGroup().location

param avnmName string = 'avnm01'
param avnmSubscriptionScope array = [subscription().id]
param avnmManagementGroupScope array = []

param rootIPAMpoolName string = 'Azure'

@maxLength(16)
param regions array = [
  {
    name: 'northeurope'
    displayName: 'North Europe'
  }
  {
    name: 'westeurope'
    displayName: 'West Europe'
  }
]

// Azure CIDR block
param AzureCIDR string = '172.16.0.0/12'

// Azure Region CIDR size
param RegionCIDRsize int = 16

// Platform Landing Zone CIDR size
param platformCIDRsize int = 21
param platformConnectivityLzCIDRsize int = 23
param platformIdentityLzCIDRsize int = 23

// Application Landing Zone CIDR size
// param applicationCIDRsize int = parseCidr()

var Regions = [
  for (region, i) in regions: {
    name: region.name
    displayName: region.displayName
    cidr: cidrSubnet(AzureCIDR, RegionCIDRsize, i)
  }
]

resource avnm 'Microsoft.Network/networkManagers@2024-07-01' = {
  name: avnmName
  location: location
  properties: {
    networkManagerScopes: {
      managementGroups: avnmManagementGroupScope
      subscriptions: avnmSubscriptionScope
    }
  }
}

resource rootIPAMpool 'Microsoft.Network/networkManagers/ipamPools@2024-07-01' = {
  name: replace(AzureCIDR, '/', '-')
  parent: avnm
  location: location
  properties: {
    addressPrefixes: [
      AzureCIDR
    ]
    displayName: rootIPAMpoolName
    description: 'Root IPAM pool for Azure CIDR block (${AzureCIDR})'
  }
}

module ipamPerRegion 'ipamPerRegion.bicep' = [
  for region in Regions: {
    name: 'ipamPerRegion-${region.name}'
    params: {
      regionDisplayName: region.displayName
      regionCIDR: region.cidr
      location: region.name
      rootIPAMpoolName: rootIPAMpool.name
      avnmName: avnm.name
      platformCIDRsize: platformCIDRsize
      platformConnectivityLzCIDRsize: platformConnectivityLzCIDRsize
      platformIdentityLzCIDRsize: platformIdentityLzCIDRsize
    }
  }
]

output RegionCIDRs array = Regions
