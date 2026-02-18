# Create Azure Migrate Project


### VARIABLES ###
$ProjectName = "Test-CMF-HyperV-Project"
$Location = "centralus"
$ResourceGroupName = "rg-Azure-Migrate"
$ApiVersion = "2020-06-01-preview"
$ConnectivityMethod = "PrivateEndpoint"
$SubscriptionId = (Get-AzContext).Subscription.Id
$VNetName = "vnet-hub"
$SubnetName = "private-endpoints"

if ($ConnectivityMethod -eq "PrivateEndpoint") {
    $TemplateFile = "../templates/azure-migrate-project-private-endpoints.json"
    $ProjectName = "$ProjectName-Private"
    Write-Host "Creating Azure Migrate Project: $ResourceGroupName -> $ProjectName in $Location" -ForegroundColor Yellow 
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -projectName $ProjectName -location $Location -vnetResourceId "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/virtualNetworks/$VNetName" -subnetResourceId "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Network/virtualNetworks/$VNetName/subnets/$SubnetName" -ApiVersion $ApiVersion -Verbose
} else {
    $TemplateFile = "../templates/azure-migrate-project-public-endpoint.json" 
    $ProjectName = "$ProjectName-Public"
    Write-Host "Creating Azure Migrate Project: $ResourceGroupName -> $ProjectName in $Location" -ForegroundColor Yellow
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -projectName $ProjectName -location $Location -ApiVersion $ApiVersion -Verbose
}

