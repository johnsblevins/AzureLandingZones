# Features
The solution contains both core and optional features.  The core features include the programmatic creation of the subscription and assignment of Custom Name and Owner at creation time.  The optional features include governance and management items that need to be performed on the subscription after creation for example moving the subscription to a different management group, setting up diagnostic logging and requiring tags.

## Core Features
The following core features are available in this solution:
* Programmatically create Enterprise Agreement (EA) Enrollment based subscription 
* Assign custom name and owner to subscription at creation time

## Optional Features
The following optional features are included in this solution:
* Subscription gets moved to requested Management Group
* Require tags created with requested values
* Need to enable diagnostic logging capabilities immediately at vending

# Suggested Prerequisites
## Existing Enterprise Landing Zone Environment
For existing enterprise landing zone environments recomend creating an 'Onboarding' or 'Staging' management group 

## New Enterprise Landing Zone Environment
For new landing zone environments recommend to utilize Cloud Adoption Framework (CAF) Enterprise Scale Landing Zone construct customized to fit your requirements.  CAF ENTLZ is documented at .  

