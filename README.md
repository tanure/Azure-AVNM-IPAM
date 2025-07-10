# Azure Virtual Network Manager (AVNM) IP Address Management (IPAM) Solution

This project provides an Azure Bicep template solution for deploying Azure Virtual Network Manager with hierarchical IP Address Management (IPAM) pools. The solution creates a structured IPAM hierarchy that supports Azure Landing Zone architectures across multiple regions.

## 🏗️ Architecture Overview

The solution creates a hierarchical IPAM structure:

```
Root IPAM Pool (Azure CIDR Block)
└── Regional IPAM Pools (per region)
    └── Platform Landing Zone Pool
        ├── Connectivity Landing Zone Pool
        └── Identity Landing Zone Pool
```

## 📋 Features

- **Multi-region support**: Automatically creates IPAM pools for multiple Azure regions
- **Hierarchical IP management**: Implements a structured approach to IP allocation
- **Azure Landing Zone alignment**: Supports platform and application landing zone patterns
- **Flexible CIDR sizing**: Configurable subnet sizes for different components
- **Automated subnet calculation**: Uses Azure Bicep CIDR functions for automatic IP allocation

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

| Parameter                        | Type   | Default                    | Description                               |
| -------------------------------- | ------ | -------------------------- | ----------------------------------------- |
| `location`                       | string | `resourceGroup().location` | Azure region for AVNM deployment          |
| `avnmName`                       | string | `'avnm01'`                 | Name of the Azure Virtual Network Manager |
| `avnmSubscriptionScope`          | array  | `[subscription().id]`      | Subscriptions in AVNM scope               |
| `avnmManagementGroupScope`       | array  | `[]`                       | Management groups in AVNM scope           |
| `rootIPAMpoolName`               | string | `'Azure'`                  | Display name for root IPAM pool           |
| `regions`                        | array  | See below                  | Array of regions to deploy                |
| `AzureCIDR`                      | string | `'172.16.0.0/12'`          | Root Azure CIDR block                     |
| `RegionCIDRsize`                 | int    | `16`                       | Subnet size for regional pools            |
| `platformCIDRsize`               | int    | `21`                       | Subnet size for platform landing zones    |
| `platformConnectivityLzCIDRsize` | int    | `23`                       | Subnet size for connectivity LZ           |
| `platformIdentityLzCIDRsize`     | int    | `23`                       | Subnet size for identity LZ               |

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
- **Platform LZ**: `172.16.0.0/21` (per region)
  - **Connectivity**: `172.16.0.0/23`
  - **Identity**: `172.16.2.0/23`

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

### Modifying CIDR Sizes

Adjust the CIDR size parameters based on your requirements:

```bicep
param RegionCIDRsize int = 14        // Larger regional pools
param platformCIDRsize int = 19      // Smaller platform pools
```

### Adding Application Landing Zones

The `ipamPerRegion.bicep` template includes examples for application landing zone CIDR calculations that can be extended.

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
