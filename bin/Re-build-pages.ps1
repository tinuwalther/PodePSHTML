#region Re-buld pages
Invoke-WebRequest -Uri http://localhost:8080/api/index   -Method Post | ConvertFrom-Json

Invoke-WebRequest -Uri http://localhost:8080/api/asset   -Method Post | Select-Object Content

Invoke-WebRequest -Uri http://localhost:8080/api/pode    -Method Post | ConvertFrom-Json

Invoke-WebRequest -Uri http://localhost:8080/api/sqlite  -Method Post -Body 'SELECT * FROM "classic_ESXiHosts" ORDER BY Notes Desc Limit 3' | ConvertFrom-Json

Invoke-WebRequest -Uri http://localhost:8080/api/pester  -Method Post -Body '["sbb.ch","admin.ch"]' | ConvertFrom-Json

Invoke-WebRequest -Uri http://localhost:8080/api/mermaid -Method Post -Body 'SELECT * FROM "classic_ESXiHosts" ORDER BY HostName' | ConvertFrom-Json

Invoke-WebRequest -Uri http://localhost:8080/api/help    -Method Post | ConvertFrom-Json
#endregion