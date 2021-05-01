param workbookdisplayname string
param workbooktype string
param workbooksourceid string
param workbookid string = '${guid(utcNow())}'
param workbookkind string='shared'
param serializeddata string

resource workbook 'Microsoft.Insights/workbooks@2020-10-20'={
  name: workbookid
  location: resourceGroup().location
  kind: workbookkind
  properties: {
    category: workbooktype
    sourceId: workbooksourceid
    displayName: workbookdisplayname
    serializedData: serializeddata    
  }  
}
