<#
.SYNOPSIS
    Create new web-page

.DESCRIPTION
    Create new pode web-page with PSHTML. Contains the layout with a jumbotron, navbar, body, content, footer.
    
.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlPodeServerPage.ps1 -Title 'Pode Server'

.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlPodeServerPage.ps1 -Title 'Pode Server' -AssetPath '/assets'
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
    $HeaderTitle          = $($Title)
    $BodyDescription      = "I ♥ PS Pode > This is an example for using pode and PSHTML"
    $FooterSummary        = "Based on "
    $BootstrapNavbarColor = 'bg-dark navbar-dark'

    $NavbarWebSiteLinks = [ordered]@{
        'https://badgerati.github.io/Pode/'                        = 'Pode docs'
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
                        
                        # <!-- Navbar Dropdown -->
                        li -class "nav-item dropdown" -Content {

                            button -class "nav-link dropdown-toggle btn btn-sm-outline" -Attributes @{
                                "type"="button"
                                "data-bs-toggle"="dropdown"
                            } -Content { 'Pode' }

                            ul -class "dropdown-menu $BootstrapNavbarColor" {

                                li -class "dropdown-item $BootstrapNavbarColor" -Content {
                                    a -class "nav-link" -href "#InstallPode" -content { 'Install Pode' }
                                }
                                li -class "dropdown-item $BootstrapNavbarColor" -Content {
                                    a -class "nav-link" -href "#ConfigurePode" -content { 'Configure Pode' }
                                }
                                li -class "dropdown-item $BootstrapNavbarColor" -Content {
                                    a -class "nav-link" -href "#StartPode" -content { 'Start Pode' }
                                }
                            }                            
                        }
                        # <!-- Navbar Dropdown -->
                        
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

    #region header
    $header = {
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

            title "#PSXi $($HeaderTitle)"
            Link -rel icon -type "image/x-icon" -href "/assets/img/favicon.ico"
        } 
    }
    #endregion header

    #region body
    $body = {
        body {

            #region <!-- header -->
            header  {
                div -id "j1" -class 'jumbotron text-center' -Style "padding:15; background-color:#033b63" -content {
                    p { h1 "#PSXi $($HeaderTitle)" }
                    #p { h2 $HeaderCaption }  
                    p { $BodyDescription }  
                }
            }
            #endregion header
            
            #region <!-- section -->
            section -id "section" -Content {  

                Invoke-Command -ScriptBlock $navbar

                #region <!-- content -->
                div -id "Content" -Class "$($ContainerStyle)" {
                
                    article -Id "Pode" -Content {

                        h1 {'Pode'} -Style "color:$($HeaderColor)"

                        p {
                            "Pode is a Cross-Platform framework to create web servers that host REST APIs, Web Sites, and TCP/SMTP Servers." 
                        } -Style "color:$($TextColor)"

                        p {
                            "It also allows you to render dynamic files using .pode files, which is effectively embedded PowerShell, or other Third-Party template engines. 
                            Pode also has support for middleware, sessions, authentication, and logging; as well as access and rate limiting features. 
                            There's also Azure Functions and AWS Lambda support!"
                        } -Style "color:$($TextColor)"

                        p {
                            'Pode and Pode.web is created by Matthew Kelly '
                            a -href "https://github.com/Badgerati" -Target _blank -content { '(Badgerati)' }
                            ', licensed under the MIT License.'
                        } -Style "color:$($TextColor)"

                        h2 -id 'InstallPode' {'How to install pode'} -Style "color:$($HeaderColor)"

                        p {
                            'You can install pode from the PowerShell-Gallery.'
                        } -Style "color:$($TextColor)"

                        pre {
                            'Install-Module -Name Pode -Verbose'
                        } -Style "color:$($TextColor)"

                        h2 -id 'ConfigurePode' {'How to configure pode'} -Style "color:$($HeaderColor)"

                        p {
                            'Create a root folder, for example PodePSHTML:'
                        } -Style "color:$($TextColor)"

                        pre {
                            'New-Item -Path . -Name PodePSHTML -ItemType Directory -Force -Confirm:$false'
                        } -Style "color:$($TextColor)"

                        p {
                            'Change in to the new directory:'
                        } -Style "color:$($TextColor)"

                        pre {
                            'Set-Location ./PodePSHTML'
                        } -Style "color:$($TextColor)"

                        p {
                            'Clone the code from my repository:'
                        } -Style "color:$($TextColor)"

                        pre {
                            'git clone https://github.com/tinuwalther/PodePSHTML.git'
                        } -Style "color:$($TextColor)"

                        h2 -id 'StartPode' {'How to start pode'} -Style "color:$($HeaderColor)"

                        p {
                            'Open a PowerShell and enter:'
                        } -Style "color:$($TextColor)"

                        pre {
                            'pwsh ./PodePSHTML/PodeServer.ps1'
                        } -Style "color:$($TextColor)"

                    }

                }
                #endregion column

            }
            #endregion section
            
        }
    }
    #endregion body

    #region footer
    $footer = {
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
                            p {"Created at $(Get-Date -f 'yyyy-MM-dd HH:mm:ss')"}
                        } -Style "color:$TextColor"
                    }
                }
        
            }
        }
    }
    #endregion footer
    
    #region HTML
    $HTML = html {
        Invoke-Command -ScriptBlock $header
        Invoke-Command -ScriptBlock $body
        Invoke-Command -ScriptBlock $footer
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
