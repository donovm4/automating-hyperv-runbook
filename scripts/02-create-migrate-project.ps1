# Create Azure Migrate Project


### VARIABLES ###
$ProjectName = "Test-CMF-HyperV-Project"
$Location = "centralus"
$ResourceGroupName = "rg-Azure-Migrate"
$ApiVersion = "2020-06-01-preview"

Write-Host "Creating Resource Group: $ResourceGroupName in $Location" -ForegroundColor Yellow
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force -Verbose 

Write-Host "Creating Azure Migrate Project: $ResourceGroupName -> $ProjectName in $Location" -ForegroundColor Yellow
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile ../templates/azure-migrate-project.json -projectName $ProjectName -location $Location -ApiVersion $ApiVersion -Verbose