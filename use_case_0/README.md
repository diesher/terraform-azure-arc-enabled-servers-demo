# Use Case 0: Deploy a GCP Windows instance and connect it to Azure Arc using a Terraform plan
The following Jumpstart scenario will guide you on how to use the provided Terraform plan to deploy a Windows Server GCP virtual machine and connect it as an Azure Arc-enabled server resource.

## Prerequisites
- Clone the following repositories
```
git clone https://github.com/diesher/terraform-azure-arc-enabled-servers-demo.git
```
- [Install or update Azure CLI to version 2.36.0 and above](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest). Use the below command to check your current installed version.
```
az --version
```
- Install Terraform >=1.1.9
- Prepare Google Cloud account
- Create Azure service principal (SP)

To connect the GCP virtual machine to Azure Arc, an Azure service principal assigned with the “Contributor” role is required. To create it, login to your Azure account run the below command (this can also be done in Azure Cloud Shell).
```
az login
subscriptionId=$(az account show --query id --output tsv)
az ad sp create-for-rbac -n "<Unique SP Name>" --role "Contributor" --scopes /subscriptions/$subscriptionId
```
- Azure Arc-enabled servers depends on the following Azure resource providers in your subscription in order to use this service. Registration is an asynchronous process, and registration may take approximately 10 minutes.
-- Microsoft.HybridCompute
-- Microsoft.GuestConfiguration
-- Microsoft.HybridConnectivity

```
az provider register --namespace 'Microsoft.HybridCompute'
az provider register --namespace 'Microsoft.GuestConfiguration'
az provider register --namespace 'Microsoft.HybridConnectivity'
```
# Automation flow
For you to get familiar with the automation and deployment flow, below is an explanation.
 1. User creates and configures a new GCP project along with a Service Account key which Terraform will use to create and manage resources
 2. User edits the tfvars to match the environment.
 3. User runs terraform init to download the required terraform providers
 4. User runs the automation. The terraform plan will:
    - Create a Windows Server VM in GCP
    - Create an Azure Resource Group
    - Install the Azure Connected Machine agent by executing a PowerShell script when the VM is first booted. Optionally a semi-automated deployment is provided if you       want to demo/control the actual registration process.
  5. User verifies the VM is create in GCP and the new Azure Arc-enabled resource in the Azure portal
