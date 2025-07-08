# azd-sample-AzureVM

This repository contains a sample project that demonstrates how to deploy an Azure Virtual Machine (VM) using the Azure Developer CLI (azd). The project is designed to help you quickly set up and manage Azure resources with minimal configuration.

## Requirements
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [Azure Developer CLI](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)

## Change Configuration

modify the `./infra/main.bicepparam` file to customize the deployment parameters.

## Setup Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/h-morozumi/azd-sample-AzureVM.git
   ```
2. Navigate to the project directory:
   ```bash
   cd azd-sample-AzureVM
   ```
3. Initialize the Azure Developer CLI project:
   ```bash
   azd init
   ```
4. execute the following command to set up the Azure resources:
   ```bash
   azd up
   ```
5. Shutdown the Azure resources when not in use:
   ```bash
   azd down
   ```

