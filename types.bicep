@export()
type _environment = {
  settings: _settings
  avnm: _avnm
}

type _avnm = {
  name: string
  subscriptioNScopes: string[]?
  managementGroupScopes: string[]?
}

type _settings = {
  rootIPAMpoolName: string
  AzureCIDR: string
  RegionCIDRsize: int
  @maxValue(32)
  @minValue(8)
  RegionCIDRsplitSize: int
}

@export()
@maxLength(16)
type _regions = {
  name: string
  displayName: string
  @maxValue(100)
  @minValue(0)
  PlatformAndApplicationSplitFactor: int
  @maxValue(100)
  @minValue(0)
  ConnectivityAndIdentitySplitFactor: int
  @maxValue(100)
  @minValue(0)
  CorpAndOnlineSplitFactor: int
  cidr: string
}[]
