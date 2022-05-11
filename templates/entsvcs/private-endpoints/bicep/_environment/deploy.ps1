param( 
    [STRING] $environment = "AzureUSGovernment",
    [Parameter(Mandatory=$true)]
    [STRING] $subscriptionid,
    [STRING] $rgname = "private-endpoint-environment",
    [STRING] $location = "usgovvirginia"
)


Login-AzAccount -Environment $environment

Select-AzSubscription $subscriptionid

$rg = New-AzResourceGroup   -Name $rgname `
                            -Location $location `
                            -force

$cred = get-credential

$random = ( get-random -Minimum 0 -Maximum 999999 ).tostring('000000') 

New-AzResourceGroupDeployment   -Name "$rgname-deploy-$random" `
                                -ResourceGroupName $rg.ResourceGroupName `
                                -TemplateFile .\main.bicep `
                                -adminUsername $cred.UserName `
                                -adminPassword $cred.password `
                                -deploymentId $random `
                                -force