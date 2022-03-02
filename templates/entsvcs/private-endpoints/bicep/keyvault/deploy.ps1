param( 
    [STRING] $environment = "AzureUSGovernment",
    [Parameter(Mandatory=$true)]
    [STRING] $subscriptionid,
    [STRING] $rgname = "private-endpoints-aks-private-cluster",
    [STRING] $location = "usgovvirginia"
)

Login-AzAccount -Environment $environment

Select-AzSubscription $subscriptionid

$rg = New-AzResourceGroup   -Name $rgname `
                            -Location $location `
                            -force

#$cred = get-credential

#$publickey = read-host "Enter Public Key: ssh-rsa AAAA..."
$publickey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8WcxqgVVH1LPTrtW4SCnI6Z7vj+5O1gTW57xxmzR+Of4FuvBJ4XMkP1h6sFVpTFPtqfEbaum1nKwhpPYUu5EoccHPa4gw3Ums1Bfm6PPr9x00rkRFMgTSISwqsIsXvnDI2b7FkyD2wHv4MLRczrD831Y64irGPtNLOgsalY4GeVUGnh1FObSrmdqyUXZjaCoVtZ7tbC+trZmrGFQtWJCk0FAi0QDwRX7g25ICLXgFtv5BSH62NKxYw7FxhpeMAMMaIhGkRstC3ZoES6fsprp5/zHwBFFyPSm4j266F4VURO8EolEPol5jef0sTOlLT/2vzL1AqVoT/L5sCM8QbNwZ"

$random = ( get-random -Minimum 0 -Maximum 999999 ).tostring('000000') 

New-AzResourceGroupDeployment   -Name "$rgname-deploy-$random" `
                                -ResourceGroupName $rg.ResourceGroupName `
                                -TemplateFile .\main.bicep `
                                -TemplateParameterFile .\main.parameters.json `
                                -aksClusterSshPublicKey "$publickey" `
                                -force