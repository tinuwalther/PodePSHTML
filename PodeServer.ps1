<#
    .SYNOPSIS
    Start Pode server

    .DESCRIPTION
    Test if it's running on Windows, then test if it's running with elevated Privileges, and start a new session if not.

    .EXAMPLE
    pwsh .\PodePSHTML\PodeServer.ps1
#>
[CmdletBinding()]
param ()

#region functions
function New-PodeUploadedFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$Watch
    )

    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', "$($function)" -Join ' ')

    Add-PodeFileWatcher -EventName Created -Path $Watch -ScriptBlock {

        try{
            switch -Regex ($FileEvent.Name){
                # Network Table
                'AllClassicVIServers\-IXNetwork' {
                    "        - Received: $($FileEvent.Name) at $($FileEvent.Timestamp)" | Out-Default
                    Start-Sleep -Seconds 5
                    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                    . D:\pode\bin\New-PshtmlVMWNetworkInventory.ps1 -InputObject (Import-Csv -Path D:\pode\uploads\AllClassicVIServers-IXNetwork.csv -Delimiter ';') -Title 'AllClassic-NetworkTable'
                }
                'AllCloudVIServers\-IXNetwork' {
                    "        - Received: $($FileEvent.Name) at $($FileEvent.Timestamp)" | Out-Default
                    Start-Sleep -Seconds 5
                    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                    . D:\pode\bin\New-PshtmlVMWNetworkInventory.ps1 -InputObject (Import-Csv -Path D:\pode\uploads\AllCloudVIServers-IXNetwork.csv -Delimiter ';') -Title 'AllCloud-NetworkTable'
                }
                # Datastore Table
                'AllClassicVIServers\-IXDatastore' {
                    "        - Received: $($FileEvent.Name) at $($FileEvent.Timestamp)" | Out-Default
                    Start-Sleep -Seconds 5
                    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                    . D:\pode\bin\New-PshtmlVMWDatastoreInventory.ps1 -InputObject (Import-Csv -Path D:\pode\uploads\AllClassicVIServers-IXDatastore.csv -Delimiter ';') -Title 'AllClassic-DatastoreTable'
                }
                'AllCloudVIServers\-IXDatastore' {
                    "        - Received: $($FileEvent.Name) at $($FileEvent.Timestamp)" | Out-Default
                    Start-Sleep -Seconds 5
                    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                    . D:\pode\bin\New-PshtmlVMWDatastoreInventory.ps1 -InputObject (Import-Csv -Path D:\pode\uploads\AllCloudVIServers-IXDatastore.csv -Delimiter ';') -Title 'AllCloud-DatastoreTable'
                }
                # vCenter Overview
                'AllCloudVIServers\-IXVCSASummary' {
                    "        - Received: $($FileEvent.Name) at $($FileEvent.Timestamp)" | Out-Default
                    Start-Sleep -Seconds 5
                    $CSVfiles = Get-ChildItem -Path 'D:/pode/uploads' -Filter '*IXVCSASummary.csv'
                    $Summary = $null
                    $Summary = foreach($item in $CSVfiles){
                        Import-Csv -Path $item.FullName -Delimiter ';'
                    }
                    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                    . D:\pode\bin\New-PshtmlVMWVCSummary.ps1 -InputObject $Summary -Title 'All-VIServerTable'
                }
                # VMware Overview
                'AllClassicVIServers\-IXVMwInfraSummary' {
                    "        - Received: $($FileEvent.Name) at $($FileEvent.Timestamp)" | Out-Default
                    Start-Sleep -Seconds 5
                    $CSVfiles = Get-ChildItem -Path 'D:/pode/uploads' -Filter '*IXVMwInfraSummary.csv'
                    $Summary = $null
                    $Summary = foreach($item in $CSVfiles){
                        Import-Csv -Path $item.FullName -Delimiter ';'
                    }
                    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                    . D:\pode\bin\New-PshtmlVMWInfraSummary.ps1 -InputObject $Summary -Title 'All-VIServerSummary'
                }
                # ESXiHost Diagram and Table
                'AllCloudVIServers\-IXESXiHostSummary' {
                    "        - Received: $($FileEvent.Name) at $($FileEvent.Timestamp)" | Out-Default
                    Start-Sleep -Seconds 5
                    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                    . D:\pode\bin\New-PshtmlVCSADiagram.ps1 -InputObject (Import-Csv -Path D:\pode\uploads\AllCloudVIServers-IXESXiHostSummary.csv -Delimiter ';') -Title 'AllCloud-VIServerDiagram'
                    . D:\pode\bin\New-PshtmlESXiHostInventory.ps1 -InputObject (Import-Csv -Path D:\pode\uploads\AllCloudVIServers-IXESXiHostSummary.csv -Delimiter ';') -Title 'AllCloud-ESXiHostTable'
                }
                # ESXiHost Diagram and Table
                'AllClassicVIServers\-IXESXiHostSummary' {
                    "        - Received: $($FileEvent.Name) at $($FileEvent.Timestamp)" | Out-Default
                    Start-Sleep -Seconds 5
                    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                    . D:\pode\bin\New-PshtmlVCSADiagram.ps1 -InputObject (Import-Csv -Path D:\pode\uploads\AllClassicVIServers-IXESXiHostSummary.csv -Delimiter ';') -Title 'AllClassic-VIServerDiagram'
                    . D:\pode\bin\New-PshtmlESXiHostInventory.ps1 -InputObject (Import-Csv -Path D:\pode\uploads\AllClassicVIServers-IXESXiHostSummary.csv -Delimiter ';') -Title 'AllClassic-ESXiHostTable'
                }
            }

            $index   = 'D:/pode/views/index.pode'
            $content = Get-Content $index
            $content -replace 'Last update\s\d{4}\-\d{2}\-\d{2}\s\d{2}\:\d{2}\:\d{2}', "Last update $(Get-Date -f 'yyyy-MM-dd HH:mm:ss')" | Set-Content -Path $index -Force -Confirm:$false

        }catch{
            Write-Warning "$($function): An error occured on line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
            "WARNING: $($function): An error occured on line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)" | Add-Content -Path "D:\pode\logs\pode_$(Get-Date -f 'yyyy-MM-dd').log" -Encoding utf8 -Force
            $Error.Clear()
        }

    }
    
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', "$($MyInvocation.MyCommand.Name)" -Join ' ')

}
#endregion

#region Main
enum OSType {
    Linux
    Mac
    Windows
}

if($PSVersionTable.PSVersion.Major -lt 6){
    $CurrentOS = [OSType]::Windows
}else{
    if($IsMacOS)  {$CurrentOS = [OSType]::Mac}
    if($IsLinux)  {$CurrentOS = [OSType]::Linux}
    if($IsWindows){$CurrentOS = [OSType]::Windows}
}
#endregion

#region Pode server
if($CurrentOS -eq [OSType]::Windows){
    Start-PodeServer {
        Write-Host "Press Ctrl. + C to terminate the Pode server" -ForegroundColor Yellow

        # Add listener to Port 8080 for Protocol http
        Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http

        # Add Logging method
        # New-PodeLoggingMethod -File -Name 'requests' -MaxDays 7 -Batch 10 | Enable-PodeRequestLogging

        # Add view
        Set-PodeViewEngine -Type Pode

        # setup session details
        # Enable-PodeSessionMiddleware -Duration 720 -Extend

        # setup form auth against windows AD (<form> in HTML)
        # New-PodeAuthScheme -Form | Add-PodeAuthWindowsAd -Name 'Login' -Groups @('XAAS-vCenter-Administrators-Compute-GS') -FailureUrl '/login' -SuccessUrl '/'
        
        # Set Pode endpoints
        Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
            Write-PodeViewResponse -Path 'Index.pode'
        }

        Add-PodeRoute -Method Get -Path '/pode' -ScriptBlock {
            Write-PodeViewResponse -Path 'Pode-Server.pode'
        }

        Add-PodeRoute -Method Get -Path '/update' -ScriptBlock {
            Write-PodeViewResponse -Path 'Update-Assets.pode'
        }

        Add-PodeRoute -Method Get -Path '/sqlite' -ScriptBlock {
            Write-PodeViewResponse -Path 'SQLite-Data.pode'
        }

        # Add File Watcher
        # New-PodeUploadedFile -Watch './PodePSHTML/uploads'

    } -RootPath $($PSScriptRoot).Replace('bin','pode')
}
#endregion