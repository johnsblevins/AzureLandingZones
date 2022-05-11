$resource_group="aks-cluster-isaac"
$name="data-fabric-aks-test"
$subscription="sandbox"
$env="test"
$private_dns_zone="/subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c/resourceGroups/aks-dns-vnet/providers/Microsoft.Network/privateDnsZones/cloudhub.privatelink.usgovvirginia.cx.aks.containerservice.azure.us"
$kubernetes_version="1.22.4"
$node_vm_size="standard_d4s_v4"
$node_count="2"
$network_plugin="kubenet"
$location="usgovvirginia"
$dns_name_prefix="testdatafabric-dns"
$vnet_subnet_id="/subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c/resourceGroups/aks-dns-vnet/providers/Microsoft.Network/virtualNetworks/cloudspokevnet/subnets/default"
$admin_username="adn"
$node_osdisk_size="30"
$nodepool_name="test"
$service_cidr="172.3.0.0/24"
$dns_service_ip="172.3.0.10"
$docker_bridge_address="172.18.0.1/16"
$subscription="f86eed1f-a251-4b29-a8b3-98089b46ce6c"
$identity_id="/subscriptions/f86eed1f-a251-4b29-a8b3-98089b46ce6c/resourceGroups/aks-cluster-isaac/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mi-isaac-aks"

az aks create   --resource-group "$resource_group" `
                --name "$name" --subscription "$subscription" `
                --tags env="$env" `
                --kubernetes-version "$kubernetes_version"  `
                --node-vm-size "$node_vm_size" `
                --node-count "$node_count" `
                --network-plugin "$network_plugin" `
                --generate-ssh-keys --location "$location" `
                --network-plugin "$network_plugin" `
                --dns-name-prefix "$dns_name_prefix" `
                --vnet-subnet-id "$vnet_subnet_id" `
                --admin-username "$admin_username" `
                --node-osdisk-size "$node_osdisk_size" `
                --nodepool-name "$nodepool_name" `
                --service-cidr "$service_cidr" `
                --dns-service-ip "$dns_service_ip" `
                --docker-bridge-address "$docker_bridge_address" `
                --enable-private-cluster `
                --disable-public-fqdn `
                --outbound-type userDefinedRouting `
                --load-balancer-sku standard `
                --assign-identity "$identity_id" `
                --enable-managed-identity `
                --private-dns-zone "$private_dns_zone"
                

