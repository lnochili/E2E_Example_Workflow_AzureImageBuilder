# Example Using Azure Image Builder in Gitihub Workflow to bake application into VM image   

>>NOTE: This is only an example 

## Overview

In this end to end example, we are going to demostrate how you can use Github Actions to take your build artifacts from your repo, and inject them into a VM image, so you can install, configure your application, and OS.  In this example, the image distribution is done as Managed Image but you can also distribute to Azure Shared Image Gallery by adding the details to the ARM Template used in this example.

In this example, Ubuntu 18.04 platform Image is customized with 
   1. nodejs and npm installation
   2. Inject artifacts from Repo
   3. Configure the nodejs server application

## Prerequisites
1. You must have a Github account and a Repo
2. Ensure you have registered for the Image Builder and other feature requirements (see code below).
3. Create a Resource Group(RG) - this will be used for running the Image Builder and also for image distribution (see code below)

###  Create a Git Repo 
Login to Github, and 'Create Repo', call it 'MyAppImageBuilder'
Import the code from this public Git Repo : https://github.com/lnochili/E2E_Example_Workflow_AzureImageBuilder

### Register and enable requirements

```bash
az feature register --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview

az feature show --namespace Microsoft.VirtualMachineImages --name VirtualMachineTemplatePreview | grep state
# wait until it says registered

# check you are registered for the providers
az provider show -n Microsoft.VirtualMachineImages | grep registrationState
az provider show -n Microsoft.Storage | grep registrationState
az provider show -n Microsoft.Compute | grep registrationState
az provider show -n Microsoft.KeyVault | grep registrationState
```

If they do not show as registered, run the commented out code below.
```bash
## az provider register -n Microsoft.VirtualMachineImages
## az provider register -n Microsoft.Storage
## az provider register -n Microsoft.Compute
## az provider register -n Microsoft.KeyVault

# assign the image builder spn rights to inject the image into the chosen resource group
az role assignment create --assignee cf32a0cc-373c-47c9-9156-0db11f6a6dfc \
    --role Contributor --scope /subscriptions/$subscriptionID/resourceGroups/$aibResourceGroup
```
Create an SPN with "Contributor" permissions to the Resource Group to be used.  Use the following command to create SPN: 
```
az ad sp create-for-rbac --sdk-auth > credentials.json
cat credentials.json
```
The output of the above command will be in the format given below. 

```
{
    "subscriptionId": "<azure_aubscription_id>",
    "tenantId": "<tenant_id>",
    "clientId": "<application_id>",
    "clientSecret": "<application_secret>",
    "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
    "resourceManagerEndpointUrl": "https://management.azure.com/",
    "activeDirectoryGraphResourceId": "https://graph.windows.net/",
    "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
    "galleryEndpointUrl": "https://gallery.azure.com/",
    "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### Create Resource Group 
Create the Resource Group in Azure Subscription if it is not existing. Image Builder service in its public preview is available only in limited Azure regions. Hence, set the location to a region where the Image builder service is availble.

```bash
aibResourceGroup="<ResourceGroupName>"
location="<AzureRegion>"  

# create resource group
az group create -n $aibResourceGroup -l $location
```
## Github Workflow (aib_e2e_github_workflow.yml) for running Azure Image Builder
Once you import the code, the repo structure will be as  below:
|_ src
|_ .github/workflows
|_ arm-template

The workflow file named aib_e2e_cli_example.yml is present in the .github/workflows directory.  
The yml file defines the workflow with the job and required steps to
1. Authenticate to Azure
2. Create the Image Builder Template resource 
3. Run the Image builder template to customize the Image  with nodejs, npm and nodejs app.
3. Creates Managed Image in the location given by the user

### Set up Azure Secrets to authenticate to Azure
Before you run this workflow, configure the Azure credentials in Github Secrets.
To do this, select  Settings -> Secrets -> Add Secret.

Copy the file contents of credentials.json and paste in the window for Secret and save the secret as  AZURE_CREDENTIALS

### Update the User inputs in ARM Template (~/arm-template/aib_template.json)
Standard Azure Resource Manager Template for Image Builder is created and pre-filled with most of the inputs and you can locate the JSON file in ~/arm-template directory.  However, there are few inputs that are dependent on the user.  All the user inputs are embbraced with < xxx > and are listed below:
1. <'imageBuilderTemplateLocation'>
2. <'subscriptionId'>
3. <'ResourceGroupName'>
4. <'ManagedImageName'>
5. <'imageLocation'>

Search for the above in the JSON file, Update inputs and commit the JSON template file.

### Update the workflow (.github/workflows/aib_e2e_github_workflow.yml)

Update the following mandatory user inputs in the workflow file, 
1. image_template_name
2. distributor_resource_group

Optionally, you can update the following inputs in the workflow file:
1.run_output_name 
2.os_type: "Linux"

Save Changes and commit the workflow file.

### Run the Workflow

The workflow is triggered whenever a change is committed to the workflow file ( aib_e2e_github_workflow.yml) or the ARM template (arm-template\aib_template.json). In order to avoid workflow execution while doing the initial changes, the code for the triggers is commented. Once you are done with all the steps mentioned above in this document, you can enable the triggers by 

* delete empty square brackets [] in  .github/workflows/aib_e2e_github_workflow.yml
* uncomment the next line ' #[ .github/workflows/aib_e2e_github_workflow.yml , aib_template.json ] '
* commit the changes 

Once you commit the changes successfully, the workflow will be triggered to run. 

It may require 15 to 20 minutes to complete the Image build process.

## Test the Image
Once the Image build workflow was run successfully, you can test the image by creating a VM from the image by following the steps gien below:

```bash
 az image show -g <distributor-resource-group> -n <ManagedImageName>

# Get the image resource Id from the output of above command 
image="/subscriptions/xxxxxxx/resourceGroups/yyyyyyy/providers/Microsoft.Compute/images/zzzzzzz"

# set vm name as per your choice
vmName="<ubuntu-nodejs-vm-name>"

# create VM
az vm create \
  --resource-group <vm-resource-group> \
  --name $vmName \
  --admin-username azureuser \
  --image $image \
  --location <vm-location> \
  --admin-password anotherPassword123!

# open ports
az vm open-port -g $aibResourceGroup -n $vmName --port 8080 --priority 100

#login to the VM using its public IP and check for the customization
nodejs --version
npm --version

# run the nodejs application
cd /var/www/myapp
nodejs nodejs_server.js
```
From your local browser, goto: `http://<ipAddress>:8080`, where the <ipAddress> is the public IP of the VM. 
If the image customization has worked, you should see a webpage with /.  
   
If you type  http://<ipAddress>:8080/helloworld, you should see 'helloworld' on the webpage.

## Clean Up 

* If you need to rerun the workflow, you need to delete the Azure Image Builder template. 

### Delete AIB Template 
```
az image builder delete -g <image_builder_resource_group>  -n <image_template_name>
```
###To cleanup all the resources created in this exercise 

Delete the VM created for testing
```
az vm delete --resource-group <vm-resource-group> --name $vmName 
```
Delete the Managed image created
```
az image delete -g $distributer-resource-group -n $ManagedImageName

```
## Next Steps
for more details on Azure Image Builder, go through documentation.
