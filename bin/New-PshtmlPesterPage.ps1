<#
.SYNOPSIS
    Create new web-page

.DESCRIPTION
    Create new pode web-page with PSHTML. Contains the layout with a jumbotron, navbar, body, content, footer.
    
.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlApiPesterPage.ps1 -Title 'Pester Result'

.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlApiPesterPage.ps1 -Title 'Pester Result' -AssetPath '/assets'
#>

[CmdletBinding()]
param (
    #Titel of the new page, will be used for the file name
    [Parameter(Mandatory=$true)]
    [String]$Title,

    #Requested by API or FileWatcher
    [Parameter(Mandatory=$true)]
    [String]$Request,

    #PesterData of the pester tests as Object
    [Parameter(Mandatory=$true)]
    [Object]$PesterData,

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
    $BodyDescription      = "I ♥ PS Pode > This is an example for using pode and PSHTML, requested by $Request"
    $FooterSummary        = "Based on "
    $BootstrapNavbarColor = 'bg-dark navbar-dark'

    $NavbarWebSiteLinks = [ordered]@{
        'https://pester.dev/' = 'Pester'
    }
    
    $PassedTests  = $PesterData.PassedCount
    $FailedTests  = $PesterData.FailedCount
    $NotRunTests  = $PesterData.NotRunCount
    $SkippedTests = $PesterData.SkippedCount
    $PesterTests  = $PesterData.Tests | Sort-Object Result | Select-Object 'Block',@{N='TestName';E={$_.ExpandedName}},'Result','Duration',@{N='Message';E={$_.ErrorRecord}}
    # $PesterTests | Out-Default
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
                        if($PassedTests -gt 0){
                            li -class "nav-item" -content {
                                a -class "nav-link" -href "#PassedTests" -content { 'Passed' }
                            }
                        }
                        if($FailedTests -gt 0){
                            li -class "nav-item" -content {
                                a -class "nav-link" -href "#FailedTests" -content { 'Failed' }
                            }
                        }
                        if($NotRunTests -gt 0){
                            li -class "nav-item" -content {
                                a -class "nav-link" -href "#NotRunTests" -content { 'NotRun' }
                            }
                        }
                        if($SkippedTests -gt 0){
                            li -class "nav-item" -content {
                                a -class "nav-link" -href "#SkippedTests" -content { 'Skipped' }
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
            Script -src $(Join-Path -Path $AssetsPath -ChildPath 'Chartjs/Chart.bundle.min.js')
    
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
                    h1 {'Result of some Pester Tests'} -Style "color:$($HeaderColor)"
                    
                    div -Class "row align-items-center" {
                        # <!-- Column left -->
                        div -Class "col-md" {
                            p {''}
                        }
                        # <!-- Column middle -->
                        div -Class "col-md" {
                            canvas -Height 300px -Width 800px -Id BarCanvas -Content "Canvas not supported in your browser"
                        }
                        # <!-- Column right -->
                        div -Class "col-md" {
                            p {''}
                        }
                    }
                }

                script -content {
                    $BarTitle = ''
                    $BarDataSet = @(
                        New-PSHTMLChartBarDataSet -Data $PassedTests  -label 'Passed'  -backgroundColor 'green'  -hoverBackgroundColor 'green'  -hoverBorderColor 'white'
                        New-PSHTMLChartBarDataSet -Data $FailedTests  -label 'Failed'  -backgroundColor 'red'    -hoverBackgroundColor 'red'    -hoverBorderColor 'white'
                        New-PSHTMLChartBarDataSet -Data $NotRunTests  -label 'NotRun'  -backgroundColor 'yellow' -hoverBackgroundColor 'yellow' -hoverBorderColor 'white'
                        New-PSHTMLChartBarDataSet -Data $SkippedTests -label 'Skipped' -backgroundColor 'blue'   -hoverBackgroundColor 'blue'   -hoverBorderColor 'white'
                    )
                    New-PSHTMLChart -Type bar -DataSet $BarDataSet -labels $BarTitle -CanvasID BarCanvas
                }

                div -id "Content" -Class "$($ContainerStyle)" {
                    article -Id "pester" -Content {
                        $SplatProperties = @{
                            Object     = $PesterTests.Where( { $_.Result -match 'Passed' } )
                            TableClass = 'table table-responsive table-striped table-hover'
                            TheadClass = "thead-dark"
                            Properties = @(
                                'Block','TestName','Result','Duration'
                            )
                        }
                        h2 -id 'PassedTests' {'Passed'} -Style "color:$($HeaderColor)"
                        ConvertTo-PSHtmlTable @SplatProperties
                    }
                    article -Id "pester" -Content {
                        $SplatProperties = @{
                            Object     = $PesterTests.Where( { $_.Result -match 'Failed' } )
                            TableClass = 'table table-responsive table-striped table-hover'
                            TheadClass = "thead-dark"
                            Properties = @(
                                'Block','TestName','Result','Duration','Message'
                            )
                        }
                        h2 -id 'FailedTests' {'Failed'} -Style "color:$($HeaderColor)"
                        ConvertTo-PSHtmlTable @SplatProperties
                    }

                    if($NotRunTests -gt 0){
                        article -Id "pester" -Content {
                            $SplatProperties = @{
                                Object     = $PesterTests.Where( { $_.Result -match 'NotRun' } )
                                TableClass = 'table table-responsive table-striped table-hover'
                                TheadClass = "thead-dark"
                                Properties = @(
                                    'Block','TestName','Result','Duration'
                                )
                            }
                            h2 -id 'NotRunTests' {'NotRun'} -Style "color:$($HeaderColor)"
                            p {'Excluded Tests by Tag name.'} -Style "color:$($TextColor)"
                            ConvertTo-PSHtmlTable @SplatProperties
                        }
                    }
                    if($SkippedTests -gt 0){
                        article -Id "pester" -Content {
                            $SplatProperties = @{
                                Object     = $PesterTests.Where( { $_.Result -match 'Skipped' } )
                                TableClass = 'table table-responsive table-striped table-hover'
                                TheadClass = "thead-dark"
                                Properties = @(
                                    'Block','TestName','Result','Duration'
                                )
                            }
                            h2 -id 'SkippedTests' {'Skipped'} -Style "color:$($HeaderColor)"
                            p {"Excluded Tests by the skip-parameter."} -Style "color:$($TextColor)"
                            ConvertTo-PSHtmlTable @SplatProperties
                        }
                    }
                }
                #endregion content
                
            }

            pre {
                'Re-builds the page: I ♥ PS > Invoke-WebRequest -Uri http://localhost:8080/api/pester -Method Post'
            } -Style "color:$($TextColor)"
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
    Get-Item $OutFile | Select-Object Name, DirectoryName, CreationTime, LastWriteTime | ConvertTo-Json
}
