<#
.SYNOPSIS
    Create new web-page

.DESCRIPTION
    Create new pode web-page with PSHTML. Contains the layout with a jumbotron, navbar, body, content, footer.
    
.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlHelpPage.ps1 -Title 'Help'

.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlHelpPage.ps1 -Title 'Help' -AssetPath '/assets'
#>

[CmdletBinding()]
param (
    #Titel of the new page, will be used for the file name
    [Parameter(Mandatory=$true)]
    [String]$Title,

    #Requested by API or FileWatcher
    [Parameter(Mandatory=$true)]
    [String]$Request,

    #Asset-path, should be public/assets on the pode server
    [Parameter(Mandatory=$false)]
    [String]$AssetsPath = '/assets'
)

begin{    
    $StartTime = Get-Date
    $function = $($MyInvocation.MyCommand.Name)
    foreach($item in $PSBoundParameters.keys){
        $params = "$($params) -$($item) $($PSBoundParameters[$item])"
    }
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', "$($function)$($params)" -Join ' ')

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
}

process{

    #region variables
    $PodePath = Join-Path -Path $($PSScriptRoot).Replace('bin','') -ChildPath 'views'
    $PodeView = (("$($Title).pode") -replace '\s', '-')
    $OutFile  = Join-Path -Path $($PodePath) -ChildPath $($PodeView)

    Write-Verbose "OutFile: $($OutFile)"
    Write-Verbose "AssetsPath: $($AssetsPath)"

    $ContainerStyle       = 'Container'
    $ContainerStyleFluid  = 'container-fluid'
    $HeaderColor          = '#212529'
    $TextColor            = '#000'
    $BootstrapNavbarColor = 'bg-dark navbar-dark'
    $NavbarWebSiteLinks = [ordered]@{
        # Anchor        = Navbar menu name
        "#RebuildByFW"  = 'Re-build by FileWatcher'
        "#RebuildByAPI" = 'Re-build by API'
    }
    #endregion variables

    #region navbar
    $navbar = {

        #region <!-- nav -->
        nav -class "navbar navbar-expand-sm $BootstrapNavbarColor sticky-top" -content {
            
            div -class $ContainerStyleFluid {
                
                a -class "navbar-brand" -href "/" -content {'»HOME'}

                # <!-- Toggler/collapsibe Button -->
                button -class "navbar-toggler" -Attributes @{
                    "type"="button"
                    "data-bs-toggle"="collapse"
                    "data-bs-target"="#collapsibleNavbar"
                } -content {
                    span -class "navbar-toggler-icon"
                }

                #region <!-- Navbar links -->
                div -class "collapse navbar-collapse" -id "collapsibleNavbar" -Content {
                    ul -class "navbar-nav" -content {
                        $NavbarWebSiteLinks.Keys | ForEach-Object {
                            li -class "nav-item" -content {
                                a -class "nav-link" -href $PSitem -content { $NavbarWebSiteLinks[$PSItem] }
                            }
                        }
                        li -class "nav-item" -content {
                            a -class "nav-link" -href '/help' -content { 'Help' }
                        }

                    }
                }
                #endregion Navbar links
            }
        }
        #endregion nav

    }
    #endregion navbar

    #region body
    $body = {
        body {

            # includes code from external script for --> header
            . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/header.ps1')
            
            #region <!-- section -->
            section -id "section" -Content {  

                Invoke-Command -ScriptBlock $navbar

                #region <!-- content -->
                div -id "Content" -Class "$($ContainerStyle)" {
                
                    article -Id "Pode" -Content {

                        h1 {'Re-build pages'} -Style "color:$($HeaderColor)"

                        h2 -id 'RebuildByFW' {'Re-build by FileWatcher'} -Style "color:$($HeaderColor)"

                        p {
                            "Re-build by FileWatcher is not supported on a Container!" 
                        } -Style "color:$($TextColor)"

                        p {
                            "Re-builds the Index.pode page:" 
                        } -Style "color:$($TextColor)"

                        pre {
                            'New-Item ./PodePSHTML/upload -Force -Name index.txt'
                        } -Style "color:$($TextColor)"

                        p {
                            "Re-builds the Pode-Server.pode page:" 
                        } -Style "color:$($TextColor)"

                        pre {
                            'New-Item ./PodePSHTML/upload -Force -Name pode.txt'
                        } -Style "color:$($TextColor)"

                        
                        p {
                            "Re-builds the Update-Assets.pode page:" 
                        } -Style "color:$($TextColor)"

                        pre {
                            'New-Item ./PodePSHTML/upload -Force -Name asset.txt'
                        } -Style "color:$($TextColor)"

                        h2 -id 'RebuildByAPI' {'Re-build by API'} -Style "color:$($HeaderColor)"

                        p {
                            "Re-builds the Index.pode page:" 
                        } -Style "color:$($TextColor)"

                        pre {
                            'Invoke-WebRequest -Uri http://localhost:8080/api/index -Method Post'
                        } -Style "color:$($TextColor)"

                        p {
                            "Re-builds the Pode-Server.pode page:" 
                        } -Style "color:$($TextColor)"

                        pre {
                            'Invoke-WebRequest -Uri http://localhost:8080/api/pode -Method Post'
                        } -Style "color:$($TextColor)"

                        p {
                            "Re-builds the Update-Assets.pode page:" 
                        } -Style "color:$($TextColor)"

                        pre {
                            'Invoke-WebRequest -Uri http://localhost:8080/api/asset -Method Post'
                        } -Style "color:$($TextColor)"

                        p {
                            "Re-builds the SQLite-Data.pode page with own sql query:" 
                        } -Style "color:$($TextColor)"

                        pre {
                            'Invoke-WebRequest -Uri http://localhost:8080/api/sqlite -Method Post -Body ''SELECT * FROM "classic_ESXiHosts" Limit 7'''
                        } -Style "color:$($TextColor)"

                        p {
                            "Re-builds the Pester-Result.pode page with own destinations to test:" 
                        } -Style "color:$($TextColor)"

                        pre {
                            'Invoke-WebRequest -Uri http://localhost:8080/api/pester -Method Post -Body ''["sbb.ch","admin.ch"]'''
                        } -Style "color:$($TextColor)"

                        p {
                            "Re-builds the Mermaid-Diagram.pode page:" 
                        } -Style "color:$($TextColor)"

                        pre {
                            'Invoke-WebRequest -Uri http://localhost:8080/api/mermaid -Method Post -Body ''SELECT * FROM "classic_ESXiHosts" ORDER BY HostName'''
                        } -Style "color:$($TextColor)"

                        p {
                            "Re-builds the Help.pode page:" 
                        } -Style "color:$($TextColor)"

                        pre {
                            'Invoke-WebRequest -Uri http://localhost:8080/api/help -Method Post'
                        } -Style "color:$($TextColor)"
                    }

                }
                #endregion column

            }

            pre {
                'Re-builds the page: I ♥ PS > Invoke-WebRequest -Uri http://localhost:8080/api/help -Method Post'
            } -Style "color:$($TextColor)"
            #endregion section
            
        }
    }
    #endregion body

    #region HTML
    $HTML = html {
        # includes code from external script for --> head
        . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/head.ps1')

        Invoke-Command -ScriptBlock $body

        # includes code from external script for --> footer
        . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/footer.ps1')
    }
    #endregion html

    #region save page
    $Html | Set-Content $OutFile -Encoding utf8
    #endregion save page
}

end{
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
    $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
    $Formatted = $TimeSpan | ForEach-Object {
        '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
    }
    Write-Verbose $('Finished in:', $Formatted -Join ' ')
    Get-Item $OutFile | Select-Object Name, DirectoryName, CreationTime, LastWriteTime | ConvertTo-Json
}
