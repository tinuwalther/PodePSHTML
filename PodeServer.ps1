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
function Invoke-FileWatcher {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$Watch
    )

    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', "$($function)", $Watch -Join ' ')

    Add-PodeFileWatcher -Name PodePSHTML -Path $Watch -ScriptBlock {

        Write-Verbose "$($FileEvent.Name) -> $($FileEvent.Type) -> $($FileEvent.FullPath)"

        $BinPath  = Join-Path -Path $($PSScriptRoot) -ChildPath 'bin'

        try{
            "        - Received: $($FileEvent.Name) at $($FileEvent.Timestamp)" | Out-Default
            switch -Regex ($FileEvent.Type){
                'Created|Changed' {
                    # Move-Item, New-Item
                    switch -Regex ($FileEvent.Name){
                        'index.txt' {
                            Start-Sleep -Seconds 3
                            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                            . $(Join-Path $BinPath -ChildPath 'New-PshtmlIndexPage.ps1') -Title 'Index'
                        }
                        'sqlite.txt' {
                            Start-Sleep -Seconds 3
                            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                            . $(Join-Path $BinPath -ChildPath 'New-PshtmlSQLitePage.ps1') -Title 'SQLite Data'
                        }
                        'pester.xml' {
                            Start-Sleep -Seconds 3
                            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                            . $(Join-Path $BinPath -ChildPath 'New-PshtmlPesterPage.ps1') -Title 'Pester Result' -File $($FileEvent.FullPath)
                        }
                        'mermaid.txt' {
                            Start-Sleep -Seconds 3
                            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                            . $(Join-Path $BinPath -ChildPath 'New-PshtmlMermaidPage.ps1') -Title 'Mermaid Diagram'
                        }
                    }

                    $index   = Join-Path -Path $($PSScriptRoot) -ChildPath 'views/index.pode'
                    $content = Get-Content $index
                    $content -replace 'Created at\s\d{4}\-\d{2}\-\d{2}\s\d{2}\:\d{2}\:\d{2}', "Created at $(Get-Date -f 'yyyy-MM-dd HH:mm:ss')" | Set-Content -Path $index -Force -Confirm:$false

                }
                'Deleted' {
                    # Move-Item, Remove-Item
                }
                'Renamed' {
                    # Rename-Item
                }
                default {
                    "        - $($FileEvent.Type): is not supported" | Out-Default
                }

            }
        }catch{
            Write-Warning "$($function): An error occured on line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
            $Error.Clear()
        }

    } -Verbose
    
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

        # Enables Error Logging
        New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

        # Add listener to Port 8080 for Protocol http
        Add-PodeEndpoint -Address localhost -Port 8080 -Protocol Http

        # Set the engine to use and render .pode files
        Set-PodeViewEngine -Type Pode

        # Add File Watcher
        $WatcherPath = Join-Path -Path $($PSScriptRoot) -ChildPath 'upload'
        Invoke-FileWatcher -Watch $WatcherPath
        
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

        Add-PodeRoute -Method Get -Path '/pester' -ScriptBlock {
            Write-PodeViewResponse -Path 'Pester-Result.pode'
        }

        Add-PodeRoute -Method Get -Path '/mermaid' -ScriptBlock {
            Write-PodeViewResponse -Path 'Mermaid-Diagram.pode'
        }

    } -Verbose
}
#endregion