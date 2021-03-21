$url = "https://raw.githubusercontent.com/johnsblevins/AzureLandingZones/master/Templates/entsvcs/stig-image-factory/azuredeploy.json"
    $imageResourceGroup = "stig-image-factory" 
    $deploymentName = "stig-image-factory" + (Get-Random)
    New-AzSubscriptionDeployment `
      -Name $deploymentName `
      -Location usgovvirginia `
      -TemplateUri $url `
      -rgName $imageResourceGroup `
      -rgLocation usgovvirginia `
      -DeploymentDebugLogLevel All