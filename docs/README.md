# Azure Virtual Network Manager (AVNM) IP Address Management (IPAM) Solution

This project provides an Azure Bicep template solution for deploying Azure Virtual Network Manager with hierarchical IP Address Management (IPAM) pools. The solution is specifically designed to align with Azure Landing Zone architectures, providing automated IP address planning and allocation across multiple regions while supporting the platform and application landing zone patterns.

::: tip Note
This solution represents a suggested approach for implementing IPAM within Azure Landing Zones. There are multiple ways to design and implement IP address management in Azure, and this template provides one opinionated solution. Organizations should evaluate their specific requirements and adapt the approach as needed for their environment.
:::

## 🎯 What's This All About?

Welcome, fellow cloud architect! 🏗️ This repository is your playground for exploring Azure IPAM in a structured, Landing Zone-friendly way. Think of it as:

- 📚 **A learning lab** - Dive into the code, break it, fix it, make it your own!
- 🎨 **An inspiration canvas** - Use these patterns as a starting point for your own IPAM masterpiece
- 🧪 **A reference cookbook** - Copy, paste, modify, and season to taste for your organization's needs
- 🎪 **A fun experiment** - Because who said IP address management can't be enjoyable?

Whether you're a seasoned Azure veteran or just starting your cloud journey, feel free to poke around, ask questions, and most importantly - have fun with it! The best way to learn is by doing, so clone it, deploy it, and see what happens. 🚀

*Remember: The cloud is your oyster, and IP addresses are the pearls! 🦪✨*

## 🏗️ Architecture Overview

The solution creates a hierarchical IPAM structure:

```
Root IPAM Pool (Azure CIDR Block)
└── Regional IPAM Pools (per region)
    ├── Platform Landing Zone Pool
    │   ├── Connectivity Landing Zone Pool
    │   └── Identity Landing Zone Pool
    └── Application Landing Zone Pool
        ├── Corp Landing Zone Pool
        └── Online Landing Zone Pool
```

## 📋 Features

- **Multi-region support**: Automatically creates IPAM pools for multiple Azure regions
- **Hierarchical IP management**: Implements a structured approach to IP allocation
- **Azure Landing Zone alignment**: Supports platform and application landing zone patterns
- **Percentage-based allocation**: Flexible CIDR allocation using configurable percentage factors
- **Automated subnet calculation**: Uses Azure Bicep CIDR functions for automatic IP allocation
- **Dynamic sizing**: Adapts to different region CIDR sizes automatically

## 🚀 Quick Start

### Prerequisites

- Azure subscription with appropriate permissions
- Azure CLI or Azure PowerShell
- Bicep CLI (latest version)

### Deployment

1. **Clone the repository**
   ```bash
   git clone https://github.com/tanure/Azure-AVNM-IPAM.git
   cd Azure-AVNM-IPAM
   ```

2. **Deploy the solution**
   ```bash
   az deployment group create \
     --resource-group <your-resource-group> \
     --template-file main.bicep \
     --parameters @parameters.json
   ```

   Or using Azure PowerShell:
   ```powershell
   New-AzResourceGroupDeployment `
     -ResourceGroupName "<your-resource-group>" `
     -TemplateFile "main.bicep" `
     -TemplateParameterFile "parameters.json"
   ```

## ⚙️ Configuration

### Main Parameters

The solution uses strongly-typed parameters defined in `types.bicep`:

| Parameter  | Type           | Description                                |
| ---------- | -------------- | ------------------------------------------ |
| `location` | string         | Azure region for AVNM deployment           |
| `ipam`     | `_environment` | IPAM environment configuration (see below) |
| `regions`  | `_regions`     | Array of regions to deploy (see below)     |

#### IPAM Environment Configuration (`_environment`)

```bicep
param ipam _environment = {
  avnm: {
    name: 'avnm01'                                   // Name of the Azure Virtual Network Manager
    subscriptioNScopes: [subscription().id]          // Subscriptions in AVNM scope
    managementGroupScopes: []                        // Management groups in AVNM scope (optional)
  }
  settings: {
    rootIPAMpoolName: 'AzureGlobal'                  // Display name for root IPAM pool
    AzureCIDR: '172.16.0.0/12'                       // Root Azure CIDR block
    RegionCIDRsize: 16                               // Subnet size for regional pools
    RegionCIDRsplitSize: 21                          // Target CIDR size for subdivision (8-32)
  }
}
```

#### Regions Configuration (`_regions`)

```bicep
param regions _regions = [
  {
    name: 'northeurope'                             // Azure region name
    displayName: 'North Europe'                     // Human-readable display name
    PlatformAndApplicationSplitFactor: 10           // % allocated to platform (0-100)
    ConnectivityAndIdentitySplitFactor: 50          // % of platform to connectivity (0-100)
    CorpAndOnlineSplitFactor: 75                    // % of application to corp (0-100)
    cidr: cidrSubnet(ipam.settings.AzureCIDR, ipam.settings.RegionCIDRsize, 0)  // Auto-calculated CIDR
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
```

## 📁 Project Structure

```
├── main.bicep              # Main template with AVNM and root IPAM pool
├── ipamPerRegion.bicep     # Module for regional IPAM pool hierarchy
├── docs/                   # Documentation (VuePress)
├── package.json            # Node.js dependencies for documentation
├── README.md               # Project overview
└── LICENSE                 # License file
```

## 🔧 Customization

### Adding More Regions

Add new regions to the `regions` parameter array:

```bicep
param regions _regions = [
  // ...existing regions...
  {
    name: 'eastus'
    displayName: 'East US'
    PlatformAndApplicationSplitFactor: 15
    ConnectivityAndIdentitySplitFactor: 60
    CorpAndOnlineSplitFactor: 80
    cidr: cidrSubnet(ipam.settings.AzureCIDR, ipam.settings.RegionCIDRsize, 2)
  }
]
```

## 📚 Additional Resources

- [Azure Virtual Network Manager Documentation](https://docs.microsoft.com/azure/virtual-network-manager/)
- [Azure IPAM Documentation](https://docs.microsoft.com/azure/virtual-network-manager/concept-ip-address-management)
- [Azure Landing Zone Architecture](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.