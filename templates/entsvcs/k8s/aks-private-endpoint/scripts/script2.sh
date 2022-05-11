resource_group="Data-Fabric"
name="data-fabric-aks-test"
subscription=""
env="test"
private_dns_zone="/subscriptions/4aee283c-5415-4d71-9f9e-42a28e652b0f/resourceGroups/data-fabric/providers/Microsoft.Network/privateDnsZones/privatelink.usgovvirginia.cx.aks.containerservice.azure.us"
kubernetes_version="1.22.4"
node_vm_size="standard_d4s_v4"
node_count="3"
network_plugin="kubenet"
location="usgovvirginia"
dns_name_prefix="testdatafabric-dns"
vnet_subnet_id="/subscriptions/4aee283c-5415-4d71-9f9e-42a28e652b0f/resourceGroups/TechOffice_connectivity/providers/Microsoft.Network/virtualNetworks/TechOffice_vnet_2/subnets/Subnet3"
admin_username="adn"
node_osdisk_size="30"
nodepool_name="test"
service_cidr="10.2.0.0/24"
dns_service_ip="10.2.0.10"
docker_bridge_address="172.17.0.1/16"
subscription="4aee283c-5415-4d71-9f9e-42a28e652b0f"
identity_id="/subscriptions/4aee283c-5415-4d71-9f9e-42a28e652b0f/resourcegroups/Data-Fabric/providers/Microsoft.ManagedIdentity/userAssignedIdentities/data-fabric-managed-identity"

create_cluster()
{
az aks create --resource-group "$resource_group" --name "$name" --subscription "$subscription" --enable-managed-identity --assign-identity "$identity_id" --tags env="$env" --kubernetes-version "$kubernetes_version"  --node-vm-size "$node_vm_size" --node-count "$node_count" --network-plugin "$network_plugin" --generate-ssh-keys --location "$location" --network-plugin "$network_plugin" --dns-name-prefix "$dns_name_prefix" --vnet-subnet-id "$vnet_subnet_id" --admin-username "$admin_username" --node-osdisk-size "$node_osdisk_size" --nodepool-name "$nodepool_name" --service-cidr "$service_cidr" --dns-service-ip "$dns_service_ip" --docker-bridge-address "$docker_bridge_address" --private-dns-zone "$private_dns_zone" --enable-private-cluster --disable-public-fqdn --outbound-type userDefinedRouting --load-balancer-sku standard
}
create_cluster