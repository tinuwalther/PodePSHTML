# To includes code from external script for --> timestamp:
# . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/timestamp.ps1')

#region Check TimeStamp and build the badge
# $out = "
# `$(if(Test-Path '$OutFile'){
#     `$(`$regex = '[0-9]{4}\-[0-9]{2}\-[0-9]{2}\s[0-9]{2}\:[0-9]{2}\:[0-9]{2}')
#     `$(`$index = Get-Content '$OutFile')
#     `$(`$created = Get-Date ([regex]::Match(`$index, `$regex).Value))
#     `$(`$diffTime = New-TimeSpan -Start `$created -End (Get-Date))
#     `$(if(`$diffTime.TotalMinutes -gt 60 -and `$diffTime.TotalMinutes -lt 1440){
#         # `$badge = 'badge badge-warning' # Bootstrap v4.6.x
#         `$badge = 'badge text-bg-warning' # Bootstrap v5.3.x
#     }elseif(`$diffTime.TotalMinutes -gt 1440){
#         # `$badge = 'badge badge-danger' # Bootstrap v4.6.x
#         `$badge = 'badge text-bg-danger' # Bootstrap v5.3.x
#     }else{
#         # `$badge = 'badge badge-success' # Bootstrap v4.6.x 
#         `$badge = 'badge text-bg-success' # Bootstrap v5.3.x
#     })
#     `$(span -class `$badge {'{0} Days {1} Hours {2} Minutes' -f `$diffTime.Days, `$diffTime.Hours, `$diffTime.Minutes})
# })
# "
#endregion TimeStamp