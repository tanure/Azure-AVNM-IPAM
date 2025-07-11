# Azure AVNM IPAM Documentation

Welcome to the Azure Virtual Network Manager (AVNM) IP Address Management (IPAM) Solution documentation.

## Overview

This solution provides an Azure Bicep template for deploying Azure Virtual Network Manager with hierarchical IP Address Management (IPAM) pools, specifically designed to align with Azure Landing Zone architectures.

## Key Features

- **Multi-region support**: Automatically creates IPAM pools for multiple Azure regions
- **Hierarchical IP management**: Implements a structured approach to IP allocation
- **Azure Landing Zone alignment**: Supports platform and application landing zone patterns
- **Percentage-based allocation**: Flexible CIDR allocation using configurable percentage factors
- **Automated subnet calculation**: Uses Azure Bicep CIDR functions for automatic IP allocation
- **Dynamic sizing**: Adapts to different region CIDR sizes automatically

## Architecture

The solution creates a hierarchical IPAM structure with:

- Root IPAM Pool (Azure CIDR Block)
- Regional IPAM Pools (per region)
  - Platform Landing Zone Pool
    - Connectivity Landing Zone Pool
    - Identity Landing Zone Pool
  - Application Landing Zone Pool
    - Corp Landing Zone Pool
    - Online Landing Zone Pool

## Quick Start

### Prerequisites

- Azure subscription with appropriate permissions
- Azure CLI or Azure PowerShell
- Bicep CLI (latest version)

### Deployment

1. Clone the repository:
   ```bash
   git clone https://github.com/tanure/Azure-AVNM-IPAM.git
   cd Azure-AVNM-IPAM
   ```

2. Deploy the solution:
   ```bash
   az deployment group create \
     --resource-group <your-resource-group> \
     --template-file main.bicep \
     --parameters @parameters.json
   ```

## Configuration

The solution uses strongly-typed parameters for configuration, including IPAM environment settings and regional configurations. See the main README.md for detailed configuration options.

## Contributing

We welcome contributions! Please see the main repository for contribution guidelines.

## License

This project is licensed under the MIT License.