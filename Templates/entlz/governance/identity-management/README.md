# App Registration Management
App registrations are “Cloud Only” accounts and can’t be synced from On-Prem AD like other interactive user accounts.   They will have to be managed separately as part of the broader Identity Management governance strategy.  O365 and Azure share the same AAD tenant association and the Identity team would own the tenant however the Azure Platform team may have elevated permissions in AAD to facilitate the creation and auditing of app registrations for use in Azure.  App Registrations will be used by DevOps platform teams to automate Azure deployment scenarios as well as by developers who leverage AAD for authenticating their applications so there should be a process that accommodates all scenarios.  I’d recommend implementing workflows in Service Now, similar to the subscription provisioning flows, to onboard, modify and remove app registrations.  In addition, there will need to be audits of account permissions, key expiration and general usage.  This can be implemented with something like a logic app or via script to generate a report and alert as needed.

People
•	IdM Team
•	Azure Platform Team

Processes
•	Onboard Service Principal
•	Modify Service Principal
•	Remove Service Principal
•	Audit Service Principal Permissions
•	Audit Service Principal Key Expiration
•	Audit Service Principal Usage

Tools
•	Azure Portal
•	Azure Management API
•	Graph API  
•	Service Now

# Grant Accounts access to Create EA Subscriptions

https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/grant-access-to-create-subscription