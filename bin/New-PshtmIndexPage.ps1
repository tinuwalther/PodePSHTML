<#
.SYNOPSIS
    Create new web-page

.DESCRIPTION
    Create new pode web-page with PSHTML. Contains the layout with a jumbotron, navbar, body, content, footer.
    
.EXAMPLE
    .\PodePSHTML\bin\New-PshtmIndexPage.ps1 -Title 'Index'

.EXAMPLE
    .\PodePSHTML\bin\New-PshtmIndexPage.ps1 -Title 'Index' -AssetPath '/assets'
#>

#Requires -Modules PSHTML

[CmdletBinding()]
param (
    #Titel of the new page, will be used for the file name
    [Parameter(Mandatory=$true)]
    [String]$Title,

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
    $CardHeaderColor      = '#fff'
    $CardTitleColor       = '#fff'
    $CardButtonColor      = '#fff'
    $HeaderTitle          = $($Title)
    $BodyDescription      = "I ♥ PS Pode > This is an example for using pode and PSHTML"
    $FooterSummary        = "Based on "
    $BootstrapNavbarColor = 'bg-dark navbar-dark'

    $NavbarWebSiteLinks = [ordered]@{
        'https://github.com/tinuwalther/'                           = 'GitLab'
        'https://www.w3schools.com/html/'                           = 'HTML'
        'https://pshtml.readthedocs.io/en/latest/'                  = 'PSHTML'
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
                    }
                }
                #endregion Navbar links
            }
        }
        #endregion nav

    }
    #endregion navbar

    #region HTML
    $HTML = html {

        #region head
        head {
            meta -charset 'UTF-8'
            meta -name 'author'      -content "Martin Walther - @tinuwalther"  
            meta -name "keywords"    -content_tag "Pode, PSHTML, PowerShell, Mermaid Diagram"
            meta -name "description" -content_tag "Builds beatuifull HTML-Files with PSHTML from native PowerShell-Scripts"

            # CSS
            Link -rel stylesheet -href $(Join-Path -Path $AssetsPath -ChildPath 'BootStrap/bootstrap.min.css')
            Link -rel stylesheet -href $(Join-Path -Path $AssetsPath -ChildPath 'style/style.css')

            # Scripts
            Script -src $(Join-Path -Path $AssetsPath -ChildPath 'BootStrap/bootstrap.bundle.min.js')
            # Script -src $(Join-Path -Path $AssetsPath -ChildPath 'Jquery/jquery.min.js')
            # Script -src $(Join-Path -Path $AssetsPath -ChildPath 'mermaid/mermaid.min.js')
            # Script {mermaid.initialize({startOnLoad:true})}
    
            title "#PSXi $($HeaderTitle)"
            Link -rel icon -type "image/x-icon" -href "/assets/img/favicon.ico"
        } 
        #endregion header

        #region body
        body {

            #region <!-- header -->
            header  {
                div -id "j1" -class 'jumbotron text-center' -Style "padding:15; background-color:#033b63" -content {
                    p { h1 "#PSXi $($HeaderTitle) Page" }
                    #p { h2 $HeaderCaption }  
                    p { $BodyDescription }  
                }
            }
            #endregion header
            
            #region <!-- section -->
            section -id "section" -Content {  

                Invoke-Command -ScriptBlock $navbar

                #region <!-- content -->
                div -Class $ContainerStyleFluid {
                    article -Id "Boxes" -Content {
                        p {''}

                        div -class "row row-cols-md-5 mb-5 text-center" -Content {

                            #<!-- Card 1 >> Pode -->
                            div -class "col" -Content {
                                div -class $CardStyle -Content {
                                    div -class "card-header py-3 text-bg-danger border-danger" -Content {
                                        h4 -class "my-0 fw-normal" -Content {'Pode Server'}
                                    } -Style "color:$CardHeaderColor"
                                    div -class "card-body" -Content {
                                        h1 -class "card-title" -Content {'Pode'} -Style "color:$CardTitleColor"
                                        p -Content {'Display how to use pode.'}
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
                                        p -Content {'Display how to update the assets.'}
                                        a -class "w-100 btn btn-lg btn-primary" -href "/update" -Content {'Open'} -Style "color:$CardButtonColor"
                                    }
                                }
                            }
                            #<!-- Card 3 >> Others -->
                            div -class "col" -Content {
                                div -class $CardStyle -Content {
                                    div -class "card-header py-3 text-bg-success border-success" -Content {
                                        h4 -class "my-0 fw-normal" -Content {'Update Assets'}
                                    } -Style "color:$CardHeaderColor"
                                    div -class "card-body" -Content {
                                        h1 -class "card-title" -Content {'Others'} -Style "color:$CardTitleColor"
                                        p -Content {'Bla, bla, bla, bla ...'}
                                        a -class "w-100 btn btn-lg btn-success" -href "/" -Content {'Open'} -Style "color:$CardButtonColor"
                                    }
                                }
                            }
                            #<!-- Card 4 >> Others -->
                            div -class "col" -Content {
                                div -class $CardStyle -Content {
                                    div -class "card-header py-3 text-bg-warning border-warning" -Content {
                                        h4 -class "my-0 fw-normal" -Content {'Update Assets'}
                                    } -Style "color:$CardHeaderColor"
                                    div -class "card-body" -Content {
                                        h1 -class "card-title" -Content {'Others'} -Style "color:$CardTitleColor"
                                        p -Content {'Bla, bla, bla, bla ...'}
                                        a -class "w-100 btn btn-lg btn-warning" -href "/" -Content {'Open'} -Style "color:$CardButtonColor"
                                    }
                                }
                            }
                            #<!-- Card 5 >> Others -->
                            div -class "col" -Content {
                                div -class $CardStyle -Content {
                                    div -class "card-header py-3 text-bg-info border-info" -Content {
                                        h4 -class "my-0 fw-normal" -Content {'Update Assets'}
                                    } -Style "color:$CardHeaderColor"
                                    div -class "card-body" -Content {
                                        h1 -class "card-title" -Content {'Others'} -Style "color:$CardTitleColor"
                                        p -Content {'Bla, bla, bla, bla ...'}
                                        a -class "w-100 btn btn-lg btn-info" -href "/" -Content {'Open'} -Style "color:$CardButtonColor"
                                    }
                                }
                            }

                        }

                    }
                }
                #endregion column

            }
            #endregion section
            
        }
        #endregion body

        #region footer
        div -Class $ContainerStyleFluid -Style "background-color:#343a40" {
            Footer {

                div -Class $ContainerStyleFluid {
                    div -Class "row align-items-center" {

                        # <!-- Column left -->
                        div -Class "col-md" {
                            p {
                                a -href "#" -Class "btn-sm btn btn-outline-success" -content { "I $([char]9829) PS >" }
                            }
                        }

                        # <!-- Column middle -->
                        div -Class "col-md" {
                            p {
                                $FooterSummary
                                a -href "https://www.powershellgallery.com/packages/Pode" -Target _blank -content { "pode" }
                                ' and '
                                a -href "https://www.powershellgallery.com/packages/PSHTML" -Target _blank -content { "PSHTML" }
                            }
                        }

                        # <!-- Column right -->
                        div -Class "col-md" {
                            p {"Runs on $([Environment]::MachineName)"}
                        } -Style "color:$TextColor"
                    }
                }
        
            }
        }
        #endregion footer

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
    "Page created: $($OutFile)"
}
