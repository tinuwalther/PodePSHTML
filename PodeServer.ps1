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
function Test-IsElevated {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [OSType]$OS
    )

    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', "$($MyInvocation.MyCommand.Name)" -Join ' ')
    if($OS -eq [OSType]::Windows){
        $user = [Security.Principal.WindowsIdentity]::GetCurrent()
        $ret  = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
    }elseif($OS -eq [OSType]::Mac){
        $ret = ((id -u) -eq 0)
    }

    Write-Verbose $ret
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', "$($MyInvocation.MyCommand.Name)" -Join ' ')
    return $ret
}

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
                            . $(Join-Path $BinPath -ChildPath 'New-PshtmlIndexPage.ps1') -Title 'Index' -Request 'FileWatcher'
                        }
                        'pode.txt' {
                            Start-Sleep -Seconds 3
                            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                            . $(Join-Path $BinPath -ChildPath 'New-PshtmlPodeServerPage.ps1') -Title 'Pode Server' -Request 'FileWatcher'
                        }
                        'asset.txt' {
                            Start-Sleep -Seconds 3
                            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                            . $(Join-Path $BinPath -ChildPath 'New-PshtmlUpdateAssetPage.ps1') -Title 'Update Assets' -Request 'FileWatcher'
                        }
                        'sqlite.txt' {
                            Start-Sleep -Seconds 3
                            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                            . $(Join-Path $BinPath -ChildPath 'New-PshtmlSQLitePage.ps1') -Title 'SQLite Data' -Request 'FileWatcher' -File $($FileEvent.FullPath)
                        }
                        'pester.txt' {
                            Start-Sleep -Seconds 3
                            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                            Import-Module Pester
                            # In a container it's possible to pass variables
                            $ContainerSplat = @{
                                Path   = $(Join-Path $BinPath -ChildPath 'Invoke-PesterResult.Tests.ps1')
                                Data   = @{ Destination = 'github.com','sbb.ch'}
                            }
                            $container  = New-PesterContainer @ContainerSplat
                            # Exclude Tests with the Tag NotRun
                            $PesterData = Invoke-Pester -Container $container -PassThru -Output None -ExcludeTagFilter NotRun
                            . $(Join-Path $BinPath -ChildPath 'New-PshtmlPesterPage.ps1') -Title 'Pester Result' -Request 'FileWatcher' -PesterData $PesterData
                
                        }
                        'mermaid.txt' {
                            Start-Sleep -Seconds 3
                            Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                            . $(Join-Path $BinPath -ChildPath 'New-PshtmlMermaidPage.ps1') -Title 'Mermaid Diagram' -Request 'FileWatcher'
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
    $Address = 'localhost'
}else{
    $Address = '*'
}

# We'll use 2 threads to handle API requests
Start-PodeServer -Thread 2 {
    Write-Host "Press Ctrl. + C to terminate the Pode server" -ForegroundColor Yellow

    # Enables Error Logging
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

    # Add listener to Port 8080 for Protocol http
    Add-PodeEndpoint -Address $Address -Port 8080 -Protocol Http

    # Set the engine to use and render .pode files
    Set-PodeViewEngine -Type Pode

    # Add File Watcher
    $WatcherPath = Join-Path -Path $($PSScriptRoot) -ChildPath 'upload'
    Invoke-FileWatcher -Watch $WatcherPath
    
    #region Set Pode endpoints for the web pages
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

    Add-PodeRoute -Method Get -Path '/help' -ScriptBlock {
        Write-PodeViewResponse -Path 'Help.pode'
    }
    #endregion

    #region Set Pode endpoints for the api
    $BinPath    = Join-Path -Path $($PSScriptRoot) -ChildPath 'bin'
    $PesterPath = Join-Path -Path $($BinPath).Replace('bin','upload') -ChildPath 'pstests.xml'

    Add-PodeRoute -Method Post -Path '/api/index' -ArgumentList @($BinPath) -ScriptBlock {
        param($BinPath)
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
        $Response = . $(Join-Path $BinPath -ChildPath 'New-PshtmlIndexPage.ps1') -Title 'Index' -Request 'API'
        Write-PodeJsonResponse -Value $Response
    }

    Add-PodeRoute -Method Post -Path '/api/pode' -ArgumentList @($BinPath) -ScriptBlock {
        param($BinPath)
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
        $Response = . $(Join-Path $BinPath -ChildPath 'New-PshtmlPodeServerPage.ps1') -Title 'Pode Server' -Request 'API'
        Write-PodeJsonResponse -Value $Response
    }

    Add-PodeRoute -Method Post -Path '/api/asset' -ArgumentList @($BinPath) -ScriptBlock {
        param($BinPath)
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
        $Response = . $(Join-Path $BinPath -ChildPath 'New-PshtmlUpdateAssetPage.ps1') -Title 'Update Assets' -Request 'API'
        Write-PodeJsonResponse -Value $Response
    }

    Add-PodeRoute -Method Post -Path '/api/sqlite' -ContentType 'application/text' -ArgumentList @($BinPath) -ScriptBlock {
        param($BinPath)
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
        $Response = . $(Join-Path $BinPath -ChildPath 'New-PshtmlSQLitePage.ps1') -Title 'SQLite Data' -Request 'API' -TsqlQuery $WebEvent.Data
        Write-PodeJsonResponse -Value $Response
    }

    Add-PodeRoute -Method Post -Path '/api/pester' -ArgumentList @($BinPath, $PesterPath) -ScriptBlock {
        param($BinPath, $PesterPath)
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
        Import-Module Pester
        # In a container it's possible to pass variables
        $ContainerSplat = @{
            Path   = $(Join-Path $BinPath -ChildPath 'Invoke-PesterResult.Tests.ps1')
            Data   = @{ Destination = 'github.com','sbb.ch'}
        }
        $container  = New-PesterContainer @ContainerSplat
        # Exclude Tests with the Tag NotRun
        $PesterData = Invoke-Pester -Container $container -PassThru -Output None -ExcludeTagFilter NotRun
        $Response = . $(Join-Path $BinPath -ChildPath 'New-PshtmlPesterPage.ps1') -Title 'Pester Result' -Request 'API' -PesterData $PesterData
        if([String]::IsNullOrEmpty($Response)){
            Write-PodeJsonResponse -Value 'Could not read pester results' -StatusCode 400
        }else{
            Write-PodeJsonResponse -Value $Response
        }
    }

    Add-PodeRoute -Method Post -Path '/api/mermaid' -ArgumentList @($BinPath) -ScriptBlock {
        param($BinPath)
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
        $Response = . $(Join-Path $BinPath -ChildPath 'New-PshtmlMermaidPage.ps1') -Title 'Mermaid Diagram' -Request 'API'
        Write-PodeJsonResponse -Value $Response
    }

    Add-PodeRoute -Method Post -Path '/api/help' -ArgumentList @($BinPath) -ScriptBlock {
        param($BinPath)
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
        $Response = . $(Join-Path $BinPath -ChildPath 'New-PshtmlHelpPage.ps1') -Title 'Help' -Request 'API'
        Write-PodeJsonResponse -Value $Response
    }
    #endregion

} -Verbose 

#endregion