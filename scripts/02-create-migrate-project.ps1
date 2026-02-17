# Create Azure Migrate Project


### VARIABLES ###
$ProjectName = "Test-CMF-HyperV-Project"
$Location = "centralus"
$ResourceGroupName = "rg-Azure-Migrate"
$ApiVersion = "2020-06-01-preview"

New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile ../templates/test.json -projectName $ProjectName -location $Location -ApiVersion $ApiVersion -Verbose