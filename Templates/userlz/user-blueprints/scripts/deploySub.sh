# Create Sub
subOwnerObjId="8b68b348-cf9b-436e-9d4b-a9633dc1c204" # Object Id of User, Group or Service Principal of subsciption owner
subName="DoNotUse15"
offerType="MS-AZR-USGOV-0017P"
enrAcctName="b5f3295f-c2be-4afb-8880-5c0ce9be2db3"  # enrAcctName=$(az billing enrollment-account list --query "[0].name" --output tsv) # xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

az rest --method post \
--url "https://management.usgovcloudapi.net/providers/Microsoft.Billing/enrollmentAccounts/$enrAcctName/providers/Microsoft.Subscription/createSubscription?api-version=2019-10-01-preview" \
--headers "{\"content-type\":\"application/json\"}" \
--body "{\"displayName\": \"$subName\", \"offerType\": \"$offerType\", \"owners\": [{\"objectId\": \"$subOwnerObjId\"}]}"