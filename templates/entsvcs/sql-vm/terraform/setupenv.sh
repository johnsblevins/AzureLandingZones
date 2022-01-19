az cloud set -n AzureUSGovernment
az login

# Get your subscription
az account list --query [].name
az account set -n Sandbox
SUBSCRIPTION=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

echo "Subscription: $SUBSCRIPTION"
echo "TenantId: $TENANT_ID"

# Create an Azure AD Service Principal for Terraform
# NOTE: You'll need appId and the password
# from the output of this command.
az ad sp create-for-rbac -n terraform-demo -role Contributor -scopes /subscriptions/$SUBSCRIPTION

# Update main.tf with Sub and service principal info

terraform init

terraform plan

terraform apply