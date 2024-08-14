<#
.SYNOPSIS
    Create new web-page

.DESCRIPTION
    Create new pode web-page with PSHTML. Contains the layout with a jumbotron, navbar, body, content, footer.
    
.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlIndexPage.ps1 -Title 'Index'

.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlIndexPage.ps1 -Title 'Index' -AssetPath '/assets'
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
    $PsHeaderColor        = '#012456'
    $TextColor            = '#000'
    $CardHeaderColor      = '#fff'
    $CardTitleColor       = '#fff'
    $CardButtonColor      = '#fff'
    $HeaderTitle          = $($Title)
    $BodyDescription      = "I ♥ PS Pode > This is an example for using pode and PSHTML, requested by $($Request)."
    $FooterSummary        = "Based on "
    $BootstrapNavbarColor = 'bg-dark navbar-dark'

    $NavbarWebSiteLinks = [ordered]@{
        'https://github.com/tinuwalther/'                           = 'GitLab'
        'https://pshtml.readthedocs.io/en/latest/'                  = 'PSHTML'
        'https://github.com/jdhitsolutions/MySQLite'                = 'mySQLite'
        'https://pester.dev/'                                       = 'Pester'
        'https://www.w3schools.com/html/'                           = 'HTML'
        'https://getbootstrap.com/'                                 = 'Bootstrap'
        'https://www.cdnpkg.com/jquery/file/jquery.min.js/'         = 'JQuery'
        'https://www.cdnpkg.com/Chart.js/file/Chart.bundle.min.js/' = 'Chart'
    }

    $CardStyle = 'card bg-secondary mb-4 rounded-3 shadow-sm'
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
                                a -class "nav-link" -href $PSitem -Target _blank -content { $NavbarWebSiteLinks[$PSItem] }
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

            #region Check TimeStamp and build the badge
            . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/timestamp.ps1')
            #endregion

            #region <!-- header -->
            header  {
                div -id "j1" -class 'jumbotron text-center' -Style "padding:15; background-color:$PsHeaderColor" -content {
                    p { h1 "#PSXi $($HeaderTitle) Page" }
                    #p { h2 $HeaderCaption }  
                    p { "$($BodyDescription) The page is $($out)" }  
                }
            }
            #endregion header
            
            #region <!-- section -->
            section -id "section" -Content {  

                Invoke-Command -ScriptBlock $navbar

                #region <!-- content -->
                div -Class $ContainerStyleFluid {
                    article -Id "Boxes" -Content {
                        p {' '}
                        
                        div -class "row row-cols-md-5 mb-5 text-center" -Content {

                            #<!-- Card 1 >> Pode -->
                            div -class "col" -Content {
                                div -class $CardStyle -Content {
                                    div -class "card-header py-3 text-bg-danger border-danger" -Content {
                                        h4 -class "my-0 fw-normal" -Content {'Pode Server'}
                                    } -Style "color:$CardHeaderColor"
                                    div -class "card-body" -Content {
                                        h1 -class "card-title" -Content {'Pode'} -Style "color:$CardTitleColor"
                                        p -Content {'Shows how to use pode.'}
                                        a -class "w-100 btn btn-lg btn-danger" -href "/pode" -Content {'Open'} -Style "color:$CardButtonColor"
                                    }
                                }
                            }
                            #<!-- Card 2 >> Assets -->
                            div -class "col" -Content {
                                div -class $CardStyle -Content {
                                    div -class "card-header py-3 text-bg-primary border-primary" -Content {
                                        h4 -class "my-0 fw-normal" -Content {'Update Assets'}
                                    } -Style "color:$CardHeaderColor"
                                    div -class "card-body" -Content {
                                        h1 -class "card-title" -Content {'Assets'} -Style "color:$CardTitleColor"
                                        p -Content {'Shows how to update the assets.'}
                                        a -class "w-100 btn btn-lg btn-primary" -href "/update" -Content {'Open'} -Style "color:$CardButtonColor"
                                    }
                                }
                            }
                            #<!-- Card 3 >> Database -->
                            div -class "col" -Content {
                                div -class $CardStyle -Content {
                                    div -class "card-header py-3 text-bg-success border-success" -Content {
                                        h4 -class "my-0 fw-normal" -Content {'Database'}
                                    } -Style "color:$CardHeaderColor"
                                    div -class "card-body" -Content {
                                        h1 -class "card-title" -Content {'SQLite'} -Style "color:$CardTitleColor"
                                        p -Content {'Get data of a SQLite-DB.'}
                                        a -class "w-100 btn btn-lg btn-success" -href "/sqlite" -Content {'Open'} -Style "color:$CardButtonColor"
                                    }
                                }
                            }
                            #<!-- Card 4 >> Pester -->
                            div -class "col" -Content {
                                div -class $CardStyle -Content {
                                    div -class "card-header py-3 text-bg-info border-info" -Content {
                                        h4 -class "my-0 fw-normal" -Content {'Pester'}
                                    } -Style "color:$CardHeaderColor"
                                    div -class "card-body" -Content {
                                        h1 -class "card-title" -Content {'Pester'} -Style "color:$CardTitleColor"
                                        p -Content {'Visualize Pester Tests.'}
                                        a -class "w-100 btn btn-lg btn-info" -href "/pester" -Content {'Open'} -Style "color:$CardButtonColor"
                                    }
                                }
                            }
                            #<!-- Card 5 >> Mermaid -->
                            div -class "col" -Content {
                                div -class $CardStyle -Content {
                                    div -class "card-header py-3 text-bg-warning border-warning" -Content {
                                        h4 -class "my-0 fw-normal" -Content {'Mermaid'}
                                    } -Style "color:$CardHeaderColor"
                                    div -class "card-body" -Content {
                                        h1 -class "card-title" -Content {'Mermaid'} -Style "color:$CardTitleColor"
                                        p -Content {'Create a Mermaid Diagram'}
                                        a -class "w-100 btn btn-lg btn-warning" -href "/mermaid" -Content {'Open'} -Style "color:$CardButtonColor"
                                    }
                                }
                            }

                        }
                        
                        pre {
                            "New-Item ./PodePSHTML/upload -Force -Name index.txt | pode.txt | asset.txt # re-builds the equivalent pode page. On load, the page calculate the age of it self and display a green or red badge."
                        } -Style "color:$($TextColor)"
    
                    }
                }
                #endregion column

            }
            #endregion section
            
        }
    }
    #endregion body

    #region HTML
    $HTML = html {
        . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/head.ps1')
        Invoke-Command -ScriptBlock $body
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
