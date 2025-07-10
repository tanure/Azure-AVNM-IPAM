param location string
param regionDisplayName string
param regionCIDR string
param rootIPAMpoolName string
param avnmName string

param platformCIDRsize int
param platformConnectivityLzCIDRsize int
param platformIdentityLzCIDRsize int

var platformCIDR = cidrSubnet(regionCIDR, platformCIDRsize, 0)
var platformConnectivityLzCIDR = cidrSubnet(platformCIDR, platformConnectivityLzCIDRsize, 0)
var platformIdentityLzCIDR = cidrSubnet(platformCIDR, platformIdentityLzCIDRsize, 1)

resource avnm 'Microsoft.Network/networkManagers@2024-07-01' existing = {
  name: avnmName
}

// Root IPAM pool for the Azure region
resource regionIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-07-01' = {
  name: replace(regionCIDR, '/', '-')
  parent: avnm
  location: location
  properties: {
    addressPrefixes: [
      regionCIDR
    ]
    parentPoolName: rootIPAMpoolName
    displayName: regionDisplayName
    description: 'IPAM pool for ${regionDisplayName} region (${regionCIDR})'
  }
}

resource platformLzIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-07-01' = {
  name: replace(platformCIDR, '/', '-')
  parent: avnm
  location: location
  properties: {
    addressPrefixes: [
      platformCIDR
    ]
    parentPoolName: regionIpamPool.name
    displayName: 'Platform Landing Zones'
    description: 'IPAM pool for Platform Landing Zones in ${regionDisplayName} region'
  }
}

resource platformConnectivityLzIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-07-01' = {
  name: replace(platformConnectivityLzCIDR, '/', '-')
  parent: avnm
  location: location
  properties: {
    addressPrefixes: [
      platformConnectivityLzCIDR
    ]
    parentPoolName: platformLzIpamPool.name
    displayName: 'Connectivity'
    description: 'IPAM pool for Platform Connectivity Landing Zone in ${regionDisplayName} region'
  }
}

resource platformIdentityLzIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-07-01' = {
  name: replace(platformIdentityLzCIDR, '/', '-')
  parent: avnm
  location: location
  properties: {
    addressPrefixes: [
      platformIdentityLzCIDR
    ]
    parentPoolName: platformLzIpamPool.name
    displayName: 'Identity'
    description: 'IPAM pool for Platform Identity Landing Zone in ${regionDisplayName} region'
  }
}

// Example: If you want specific remaining subnets for application landing zones
var applicationLzCIDR1 = cidrSubnet(regionCIDR, platformCIDRsize, 1)
var applicationLzCIDR2 = cidrSubnet(regionCIDR, platformCIDRsize, 2)
var applicationLzCIDR3 = cidrSubnet(regionCIDR, platformCIDRsize, 3)
