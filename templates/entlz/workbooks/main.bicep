param entlzprefix string
param location string
param workbookdisplayname string
param workbookname string
param serializeddata string
param workbooktype string = 'workbook'
param workbooksourceid string = 'Azure Monitor'
param workbookkind string = 'shared'

targetScope = 'subscription'

resource workbookrg 'Microsoft.Resources/resourceGroups@2021-01-01'={
  name: '${entlzprefix}-workbooks-${location}'
  location: location
}

module workbook 'modules/workbook.bicep'= {
  name: workbookname
  scope: workbookrg
  dependsOn:[
    workbookrg    
  ]
  params:{
    workbookdisplayname: workbookdisplayname
    workbookkind: workbookkind
    workbooksourceid: workbooksourceid
    workbooktype: workbooktype
    serializeddata: serializeddata
  }
}
