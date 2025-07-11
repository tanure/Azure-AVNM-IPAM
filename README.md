# Azure Virtual Network Manager (AVNM) IP Address Management (IPAM) Solution

This project provides | `RegionCIDRsplitSize`                | int    | `24`                       | Target CIDR size for subdivision granularity (8-32)  |n Azure Bicep template solution for deploying Azure Virtual Network Manager with hierarchical IP Address Management (IPAM) pools. The solution creates a structured IPAM hierarchy that supports Azure Landing Zone architectures across multiple regions.

## 🏗️ Architecture Overview

The solution creates a hierarchical IPAM structure:

```mermaid
graph TD
    A[Root IPAM Pool<br/>Azure CIDR Block<br/>172.16.0.0/12] --> B[Regional Pool - North Europe<br/>172.16.0.0/16]
    A --> C[Regional Pool - West Europe<br/>172.17.0.0/16]
    A --> D[Regional Pool - Other Regions<br/>172.x.0.0/16]
    
    B --> E[Platform Landing Zones<br/>64 × /24 subnets<br/>25% allocation]
    B --> F[Application Landing Zones<br/>192 × /24 subnets<br/>75% allocation]
    
    E --> G[Connectivity LZ<br/>32 × /24 subnets<br/>50% of platform]
    E --> H[Identity LZ<br/>32 × /24 subnets<br/>50% of platform]
    
    F --> I[Corp LZ<br/>115 × /24 subnets<br/>60% of application]
    F --> J[Online LZ<br/>77 × /24 subnets<br/>40% of application]
    
    style A fill:#2563eb,stroke:#1e40af,stroke-width:2px,color:#ffffff
    style B fill:#7c3aed,stroke:#5b21b6,stroke-width:2px,color:#ffffff
    style C fill:#7c3aed,stroke:#5b21b6,stroke-width:2px,color:#ffffff
    style D fill:#7c3aed,stroke:#5b21b6,stroke-width:2px,color:#ffffff
    style E fill:#dc2626,stroke:#991b1b,stroke-width:2px,color:#ffffff
    style F fill:#059669,stroke:#047857,stroke-width:2px,color:#ffffff
    style G fill:#ea580c,stroke:#c2410c,stroke-width:2px,color:#ffffff
    style H fill:#ea580c,stroke:#c2410c,stroke-width:2px,color:#ffffff
    style I fill:#16a34a,stroke:#15803d,stroke-width:2px,color:#ffffff
    style J fill:#16a34a,stroke:#15803d,stroke-width:2px,color:#ffffff
```

**Text Representation:**
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
   git clone <repository-url>
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

| Parameter                            | Type   | Default                    | Description                                           |
| ------------------------------------ | ------ | -------------------------- | ----------------------------------------------------- |
| `location`                           | string | `resourceGroup().location` | Azure region for AVNM deployment                      |
| `avnmName`                           | string | `'avnm01'`                 | Name of the Azure Virtual Network Manager             |
| `avnmSubscriptionScope`              | array  | `[subscription().id]`      | Subscriptions in AVNM scope                           |
| `avnmManagementGroupScope`           | array  | `[]`                       | Management groups in AVNM scope                       |
| `rootIPAMpoolName`                   | string | `'Azure'`                  | Display name for root IPAM pool                       |
| `regions`                            | array  | See below                  | Array of regions to deploy                            |
| `AzureCIDR`                          | string | `'172.16.0.0/12'`          | Root Azure CIDR block                                 |
| `RegionCIDRsize`                     | int    | `16`                       | Subnet size for regional pools                        |
| `RegionCIDRspliSize`                 | int    | `24`                       | Target CIDR size for subdivision granularity (8-32)   |
| `PlatformAndApplicationSplitFactor`  | int    | `25`                       | % of region CIDRs allocated to platform (0-100)       |
| `ConnectivityAndIdentitySplitFactor` | int    | `50`                       | % of platform CIDRs allocated to connectivity (0-100) |
| `CorpAndOnlineSplitFactor`           | int    | `60`                       | % of application CIDRs allocated to corp (0-100)      |

### Regions Configuration

```bicep
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
```

### CIDR Allocation Example

With default settings:
- **Root CIDR**: `172.16.0.0/12` (172.16.0.0 - 172.31.255.255)
- **Region 1**: `172.16.0.0/16` (North Europe)
- **Region 2**: `172.17.0.0/16` (West Europe)

For each region with `/24` subdivision and `25%` platform allocation:
- **Total /24 subnets available**: 256 (from /16 to /24)
- **Platform allocation**: 64 subnets (25% of 256)
- **Application allocation**: 192 subnets (75% of 256)

**Platform Landing Zones** (with 50% connectivity split):
- **Connectivity**: 32 /24 subnets
- **Identity**: 32 /24 subnets

**Application Landing Zones** (with 60% corp split):
- **Corp**: 115 /24 subnets (60% of 192)
- **Online**: 77 /24 subnets (40% of 192)

## 📁 Project Structure

```
├── main.bicep              # Main template with AVNM and root IPAM pool
├── ipamPerRegion.bicep     # Module for regional IPAM pool hierarchy
├── README.md               # This file
└── LICENSE                 # License file
```

## 🔧 Customization

### Adding More Regions

Add new regions to the `regions` parameter:

```bicep
{
  name: 'eastus'
  displayName: 'East US'
}
```

### Modifying Allocation Factors

Adjust the percentage factors based on your requirements:

```bicep
param PlatformAndApplicationSplitFactor int = 30    // 30% to platform, 70% to application
param ConnectivityAndIdentitySplitFactor int = 40   // 40% connectivity, 60% identity
param CorpAndOnlineSplitFactor int = 70             // 70% corp, 30% online
```

### Changing Subdivision Granularity

Modify the `RegionCIDRsplitSize` to change the granularity of CIDR subdivision:

```bicep
param RegionCIDRsplitSize int = 22        // Creates /22 subnets instead of /24
```

### Regional IPAM Pool Configuration

Each region can have different factor configurations by modifying the module parameters in `main.bicep`.

## 🔍 Monitoring and Management

After deployment, you can:

1. **View IPAM pools** in the Azure portal under Network Manager
2. **Monitor IP allocation** through Azure Monitor
3. **Manage pool hierarchy** using Azure CLI or PowerShell

### Useful Commands

```bash
# List IPAM pools
az network manager ipam-pool list --network-manager-name <avnm-name> --resource-group <rg-name>

# Show specific pool details
az network manager ipam-pool show --name <pool-name> --network-manager-name <avnm-name> --resource-group <rg-name>
```

## 🛡️ Security Considerations

- AVNM requires appropriate RBAC permissions
- Consider network security groups and Azure Firewall integration
- Implement proper access controls for IPAM pool management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📚 Additional Resources

- [Azure Virtual Network Manager Documentation](https://docs.microsoft.com/azure/virtual-network-manager/)
- [Azure IPAM Documentation](https://docs.microsoft.com/azure/virtual-network-manager/concept-ip-address-management)
- [Azure Landing Zone Architecture](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
- [Bicep Documentation](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)

## 🐛 Troubleshooting

### Common Issues

1. **Insufficient permissions**: Ensure the deployment principal has Network Contributor role
2. **CIDR conflicts**: Verify that your CIDR blocks don't overlap with existing networks
3. **Region availability**: Confirm that AVNM is available in your target regions

### Support

For issues and questions:
1. Check the [Issues](../../issues) section
2. Review Azure documentation
3. Contact your Azure support team for deployment-specific issues

## 💡 Key Concepts

### Percentage-Based Allocation

The solution uses three percentage factors to dynamically allocate CIDR blocks:

1. **PlatformAndApplicationSplitFactor**: Determines what percentage of the region's subdivided CIDRs go to platform vs application landing zones (0-100%)
2. **ConnectivityAndIdentitySplitFactor**: Within platform, determines the split between connectivity and identity landing zones (0-100%)
3. **CorpAndOnlineSplitFactor**: Within application, determines the split between corporate and online landing zones (0-100%)

### Dynamic Subdivision

- The `RegionCIDRsplitSize` parameter controls the granularity of CIDR subdivision (valid range: 8-32)
- For example, with a `/16` region CIDR and `RegionCIDRsplitSize` of `24`, you get 256 `/24` subnets to allocate
- These subnets are then distributed based on the percentage factors
- Percentage factors can range from 0-100, allowing for flexible allocation including 0% allocation to any category

### Hierarchical Structure

Each level in the IPAM hierarchy can contain multiple CIDR blocks, providing flexibility and efficient IP space utilization:
- Regional pools contain the full regional CIDR
- Platform/Application pools contain arrays of allocated subnets
- Landing zone pools contain their respective allocated subnets
