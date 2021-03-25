resource mgLock 'Microsoft.Authorization/locks@2016-09-01'={
  name: 'rgLock'
  properties: {
    level: 'ReadOnly'    
  }
}
