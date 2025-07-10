param location string
param regionDisplayName string
param regionCIDR string
param rootIPAMpoolName string
param avnmName string

param platformCIDRsize int
param platformConnectivityLzCIDRsize int
param platformIdentityLzCIDRsize int

// Factor to divide the platform CIDR into application landing zone Corp and Online. in percentage
@maxValue(100)
@minValue(1)
param applicationLzFactor int

// Calculate the total number of CIDR blocks available for the platform size
// note: maximum array count is 800, so platformCIDRsize must be less than or equal to 25 (=512 CIDR blocks)
var powersOfTwo = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512]
var totalCIDRcount = powersOfTwo[platformCIDRsize - int(split(regionCIDR, '/')[1])]

// Generate possible CIDR blocks for the platform size
var totalCIDRs = [for i in range(0, totalCIDRcount): cidrSubnet(regionCIDR, platformCIDRsize, i)]

// Calculate the platform CIDR block based on the region CIDR and platform CIDR size
var platformLzCIDR = take(totalCIDRs, 1)[0]
var platformConnectivityLzCIDR = cidrSubnet(platformLzCIDR, platformConnectivityLzCIDRsize, 0)
var platformIdentityLzCIDR = cidrSubnet(platformLzCIDR, platformIdentityLzCIDRsize, 1)

// Calculate the CIDRs for application landing zones
var applicationLzCIDRs = skip(totalCIDRs, 1)
var totalRemainingCount = length(applicationLzCIDRs)
var applicationLzCorpCount = totalRemainingCount * applicationLzFactor / 100

var applicationLzCorpCIDRs = take(applicationLzCIDRs, applicationLzCorpCount)
var applicationLzOnlineCIDRs = skip(applicationLzCIDRs, applicationLzCorpCount)

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
  name: replace(platformLzCIDR, '/', '-')
  parent: avnm
  location: location
  properties: {
    addressPrefixes: [
      platformLzCIDR
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

resource applicationLzIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-07-01' = {
  name: '${parseCidr(string(first(applicationLzCIDRs))).network}-${parseCidr(string(last(applicationLzCIDRs))).broadcast}'
  parent: avnm
  location: location
  properties: {
    addressPrefixes: applicationLzCIDRs
    parentPoolName: regionIpamPool.name
    displayName: 'Application Landing Zones'
    description: 'IPAM pool for Application Landing Zones in ${regionDisplayName} region'
  }
}

resource applicationLzCorpIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-07-01' = {
  name: '${parseCidr(string(first(applicationLzCorpCIDRs))).network}-${parseCidr(string(last(applicationLzCorpCIDRs))).broadcast}'
  parent: avnm
  location: location
  properties: {
    addressPrefixes: applicationLzCorpCIDRs
    parentPoolName: applicationLzIpamPool.name
    displayName: 'Corp'
    description: 'IPAM pool for Application Corp Landing Zones in ${regionDisplayName} region'
  }
}

resource applicationLzOnlineIpamPool 'Microsoft.Network/networkManagers/ipamPools@2024-07-01' = {
  name: '${parseCidr(string(first(applicationLzOnlineCIDRs))).network}-${parseCidr(string(last(applicationLzOnlineCIDRs))).broadcast}'
  parent: avnm
  location: location
  properties: {
    addressPrefixes: applicationLzOnlineCIDRs
    parentPoolName: applicationLzIpamPool.name
    displayName: 'Online'
    description: 'IPAM pool for Application Online Landing Zones in ${regionDisplayName} region'
  }
}
