param workbookdisplayname string
param workbooktype string
param workbooksourceid string
param workbookname string
param workbookkind string='shared'
param serializeddata string

resource workbook 'Microsoft.Insights/workbooks@2020-10-20'={
  name: workbookname
  location: resourceGroup().location
  kind: workbookkind
  properties: {
    category: workbooktype
    sourceId: workbooksourceid
    displayName: workbookdisplayname
    serializedData: serializeddata    
  }  
}
