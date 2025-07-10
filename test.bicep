// Azure CIDR block
param AzureCIDR string = '172.16.0.0/12'
// Azure Region CIDR size
param RegionCIDRsize int = 16

// Platform Landing Zone CIDR size
@maxValue(25)
param platformCIDRsize int = 21

var regionCIDR = cidrSubnet(AzureCIDR, RegionCIDRsize, 0)

var powersOfTwo = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512]
var totalCIDRcount = powersOfTwo[(platformCIDRsize - RegionCIDRsize)]

var possiblePlatformCIDRs = [for i in range(0, totalCIDRcount): cidrSubnet(regionCIDR, platformCIDRsize, i)]
var remainingPlformCIDRs = skip(possiblePlatformCIDRs, 1)
// Factor to divide the platform CIDR into application landing zone Corp and Online. in percentage
@maxValue(100)
@minValue(1)
param applicationLzFactor int = 10

var totalRemainingCount = length(remainingPlformCIDRs)
var applicationLzCorpCount = totalRemainingCount * applicationLzFactor / 100
var applicationLzOnlineCount = totalRemainingCount - applicationLzCorpCount

var applicationLzCorpCIDRs = take(remainingPlformCIDRs, applicationLzCorpCount)
var applicationLzOnlineCIDRs = skip(remainingPlformCIDRs, applicationLzCorpCount)

output remainingPlformCIDRs array = remainingPlformCIDRs
output count int = length(remainingPlformCIDRs)

// output test string = '${split(first(remainingPlformCIDRs),'/')[0]}-${split(last(remainingPlformCIDRs),'/')[0]}'
output test2 string = '${parseCidr(string(first(remainingPlformCIDRs))).network}-${parseCidr(string(last(remainingPlformCIDRs))).broadcast}'
output appLzCorpCount int = applicationLzCorpCount
output appLzOnlineCount int = applicationLzOnlineCount
output appLzCorpCIDRs array = applicationLzCorpCIDRs
output appLzOnlineCIDRs array = applicationLzOnlineCIDRs
