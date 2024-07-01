<#
.SYNOPSIS
    New-PshtmlFile.ps1

.DESCRIPTION
    New-PshtmlFile - Create a Mermaid Class Diagram.
    
.EXAMPLE
    .\New-PshtmlFile.ps1 -Title 'PSHTML ESXiHost Inventory'
#>

#Requires -Modules PSHTML

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]$Title,

    [Parameter(Mandatory=$false)]
    [String]$AssetsPath = '/assets' #'../assets' #$AssetsPath = $($PSScriptRoot).Replace('bin','assets')
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

    # for Pode Server
    $PodePath = Join-Path -Path $($PSScriptRoot).Replace('bin','') -ChildPath 'views'
    $PodeView = (("$($Title).pode") -replace '\s', '-')
    $OutFile  = Join-Path -Path $($PodePath) -ChildPath $($PodeView)
    Write-Verbose "OutFile: $($OutFile)"
    
    Write-Verbose "AssetsPath: $($AssetsPath)"

    $ContinerStyleFluid  =  'Container' # 'container-fluid'

    #region header
    $HeaderTitle        = $($Title)
    #endregion

    #region color
    $HeaderColor  = '#212529' #'#ccc'
    $TextColor    = '#000' #'#ccc'
    #region

    #region body
    $BodyDescription = "I ♥ PS Pode > This is an example for using pode and PSHTML"
    #endregion    

    #region footer
    $FooterSummary = "Based on "
    #endregion

    #region scriptblock
    $navbar = {

        #region <!-- nav -->
        nav -class "navbar navbar-expand-sm bg-dark navbar-dark sticky-top" -content {
            
            div -class "container-fluid" {
                
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
                        #DynamicLinks
                        $InputObject | Group-Object $Column.Field01 | Select-Object -ExpandProperty Name | ForEach-Object {
                            $vCenter = $($_).Split('.')[0]
                            if(-not([String]::IsNullOrEmpty($vCenter))){
                                li -class "nav-item" -content {
                                    a -class "nav-link" -href "#$($vCenter)" -content { $($vCenter) }
                                }
                            }
                        }
                    }
                }
                #endregion Navbar links
            }
        }
        #endregion nav

    }

    <#
    $article = {

        #region <!-- vCenter -->
        $InputObject | Group-Object $Column.Field01 | Select-Object -ExpandProperty Name | ForEach-Object {

            #region <!-- Content -->
            div -id "Content" -Class "$($ContinerStyleFluid)" -Style "background-color:#142440" {

                #region  <!-- article -->
                article -id "mermaid" -Content {

                    $vcNo ++
                    $vCenter = ($($_).Split('.')[0]).ToUpper()

                    if(-not([String]::IsNullOrEmpty($vCenter))){

                        h3 -Id $($vCenter) -Content {
                            a -href "https://$($_)/ui/" -Target _blank -content { "vCenter $($vCenter)" }
                        } -Style "text-align: center"
                        hr

                        #region ESXiHosts
                        $InputObject | Where-Object $Column.Field01 -match $_ | Group-Object vCenterServer | ForEach-Object {
                            $TotalESXiHost = span -class "badge bg-primary" -Content { "$($_.Count) ESXiHosts" }
                            $TotalCluster  = span -class "badge bg-info" -Content { "$($_.Group.Cluster | Group-Object | Measure-Object -Property Count | Select-Object -ExpandProperty Count) Cluster" }
                            $CountOfVersion = $_.Group.Version | Group-Object | ForEach-Object {
                                if($($_.Name) -match '^6.0'){
                                    span -class "badge bg-dark" -Content "$($_.Name) ($($_.Count))"
                                }
                                if($($_.Name) -match '^6.5'){
                                    span -class "badge bg-danger" -Content "$($_.Name) ($($_.Count))"
                                }
                                if($($_.Name) -match '^6.7'){
                                    span -class "badge bg-warning" -Content "$($_.Name) ($($_.Count))"
                                }
                                if($($_.Name) -match '^7'){
                                    span -class "badge bg-success" -Content "$($_.Name) ($($_.Count))"
                                }
                            }
                            p { 
                                "Total in $($vCenter):  $($TotalCluster) $($TotalESXiHost) $($CountOfVersion)"
                            } -Style "color:$TextColor" #f8f9fa
                        }
                        #endregion

                        #region mermaid
                        div -Class "mermaid" -Style "text-align: center" {
                            
                            "classDiagram`n"

                            #region Group Cluster
                            $InputObject | Where-Object $Column.Field01 -match $_ | Group-Object $Column.Field02 | Select-Object -ExpandProperty Name | ForEach-Object {
                                
                                if(-not([String]::IsNullOrEmpty($_))){

                                    $ClusterNo ++
                                    $RootCluster = $_
                                    $FixCluster  = $RootCluster -replace '-'

                                    # Print out vCenter --> Cluster
                                    "VC$($vcNo)_$($vCenter) $($RelationShip) VC$($vcNo)C$($ClusterNo)_$($FixCluster)`n"
                                    "VC$($vcNo)_$($vCenter) : + $($RootCluster)`n"

                                    #region Group Model
                                    $InputObject | Where-Object $Column.Field01 -match $vCenter | Where-Object $Column.Field02 -match $RootCluster | Group-Object $Column.Field03 | Select-Object -ExpandProperty Name | ForEach-Object {
                                        
                                        Write-Verbose "Model: $($_)"

                                        $ModelNo ++
                                        $RootModel = $_
                                        $FixModel  = $RootModel -replace '-' -replace '\(' -replace '\)'

                                        "VC$($vcNo)C$($ClusterNo)_$($FixCluster) : + $($RootModel)`n"
                    
                                        "VC$($vcNo)C$($ClusterNo)_$($FixCluster) $($RelationShip) VC$($vcNo)C$($ClusterNo)_$($FixModel)`n"
                                                
                                        #region Group PhysicalLocation
                                        $InputObject | Where-Object $Column.Field01 -match $vCenter | Where-Object $Column.Field02 -match $RootCluster | Where-Object $Column.Field03 -match $RootModel | Group-Object $Column.Field04 | Select-Object -ExpandProperty Name | ForEach-Object {

                                            Write-Verbose "PhysicalLocation $($_)"
                                            $PhysicalLocation = $_
                                            $ObjectCount = $InputObject | Where-Object $Column.Field01 -match $vCenter | Where-Object $Column.Field02 -match $RootCluster | Where-Object $Column.Field03 -match $RootModel | Where-Object $Column.Field04 -match $PhysicalLocation | Select-Object -ExpandProperty $Column.Field05
                                            
                                            "VC$($vcNo)C$($ClusterNo)_$($FixModel) : - $($PhysicalLocation), $($ObjectCount.count) ESXi Hosts`n"

                                            "VC$($vcNo)C$($ClusterNo)_$($FixModel) $($RelationShip) VC$($vcNo)C$($ClusterNo)_$($PhysicalLocation)`n"

                                            #region Group HostName
                                            $InputObject | Where-Object $Column.Field01 -match $vCenter | Where-Object $Column.Field02 -match $RootCluster | Where-Object $Column.Field03 -match $RootModel | Where-Object $Column.Field04 -match $PhysicalLocation | Group-Object $Column.Field05 | Select-Object -ExpandProperty Name | ForEach-Object {
                                                
                                                $HostObject = $InputObject | Where-Object $Column.Field05 -match $($_)
                                                $ESXiHost   = $($HostObject.$($Column.Field05)).Split('.')[0]

                                                if($HostObject.$($Column.Field06) -eq 'Connected'){
                                                    $prefix = '+'
                                                }elseif($HostObject.$($Column.Field06) -match 'New'){
                                                    $prefix = 'o'
                                                }else{
                                                    $prefix = '-'
                                                }

                                                "VC$($vcNo)C$($ClusterNo)_$($PhysicalLocation) : $($prefix) $($ESXiHost), ESXi $($HostObject.Version), $($RootModel)`n"
                                            }
                                            #endregion HostName
                                            
                                        }
                                        #endregion PhysicalLocation
                                    
                                        $ModelNo = 0
                                    }
                                    #endregion Group Model

                                }else{
                                    Write-Verbose "Empty Cluster"
                                }

                            }
                            #endregion Group Cluster

                            $ClusterNo = 0
                        }
                        #endregion mermaid

                    }else{
                        Write-Verbose "Emptry vCenter"
                    }

                }
                #endregion article

            }
            #endregion content
        } 
        #endregion vCenter

        #region ESXiHosts
        hr
        div -id "Content" -Class "$($ContinerStyleFluid)" -Style "background-color:#142440" {
            article -id "ESXiHosts" -Content {
                $TotalESXiHost = span -class "badge bg-primary" -Content { "$(($InputObject.$($Column.Field01)).count) ESXiHosts" }
                $CountOfVersion = $InputObject | Group-Object Version | ForEach-Object {
                    if($($_.Name) -match '^6.0'){
                        span -class "badge bg-dark" -Content "$($_.Name) ($($_.Count))"
                    }
                    if($($_.Name) -match '^6.5'){
                        span -class "badge bg-danger" -Content "$($_.Name) ($($_.Count))"
                    }
                    if($($_.Name) -match '^6.7'){
                        span -class "badge bg-warning" -Content "$($_.Name) ($($_.Count))"
                    }
                    if($($_.Name) -match '^7'){
                        span -class "badge bg-success" -Content "$($_.Name) ($($_.Count))"
                    }
                }
                p {
                    "Total: $($TotalESXiHost) $($CountOfVersion)"
                } -Style "color:$TextColor" #f8f9fa
            }
        }
        #endregion

    }
    #endregion scriptblock
    #>

    #region HTML
    $HTML = html {

        #region head
        head {
            meta -charset 'UTF-8'
            meta -name 'author' -content "Martin Walther"  
            meta -name "keywords" -content_tag "PSHTML, PowerShell, Mermaid Diagram"
            meta -name "description" -content_tag "PsMmaDiagram builds Mermaid Diagrams as HTML-Files with PSHTML from native PowerShell-Scripts"

            # CSS
            Link -rel stylesheet -href $(Join-Path -Path $AssetsPath -ChildPath 'BootStrap/bootstrap.min.css')
            Link -rel stylesheet -href $(Join-Path -Path $AssetsPath -ChildPath 'style/style.css')

            # Scripts
            Script -src $(Join-Path -Path $AssetsPath -ChildPath 'BootStrap/bootstrap.bundle.min.js')
            Script -src $(Join-Path -Path $AssetsPath -ChildPath 'Jquery/jquery.min.js')
    
            title $HeaderTitle
            Link -rel icon -type "image/x-icon" -href "/assets/img/favicon.ico"
        } 
        #endregion header

        #region body
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
                div -id "Content" -Class "$($ContinerStyleFluid)" {
                
                    article -Id "Bootstrap" -Content {

                        h1 {'Bootstrap'} -Style "text-align: center; color:$($HeaderColor)"

                        p {
                            $BootstrapJsPath    = $(Join-Path -Path $($PSScriptRoot).Replace('bin','public') -ChildPath 'assets/BootStrap/bootstrap.bundle.min.js')
                            $BootstrapJsString  = Get-Content -Path $BootstrapJsPath -TotalCount 2
                            $BootstrapJsVersion = [regex]::Match($BootstrapJsString, '\d\.\d\.\d')
                            b {"Current JavaScript version: $($BootstrapJsVersion), "}
                            
                            $BootstrapCssPath    = $(Join-Path -Path $($PSScriptRoot).Replace('bin','public') -ChildPath 'assets/BootStrap/bootstrap.min.css')
                            $BootstrapCssString  = Get-Content -Path $BootstrapCssPath -TotalCount 2
                            $BootstrapCssVersion = [regex]::Match($BootstrapCssString, '\d\.\d\.\d')
                            b {"current CSS version: $($BootstrapCssVersion)"}
                        } -Style "color:#50C878"

                        h2 {'How to update Bootstrap'} -Style "text-align: center; color:$($HeaderColor)"

                        p {
                            'Open '
                            a -href "https://getbootstrap.com/" -Target _blank -content { 'Bootstrap' }
                            " and scroll down to "; b {'Include via CDN.'}

                        } -Style "color:$($TextColor)"

                        p {
                            "Browse to the URL in link href of the bootstrap.min.css, mark the whole content, and copy & paste the content in to your bootstrap.min.css-file."
                        } -Style "color:$($TextColor)"

                        p {
                            "Browse to the URL in script src of the bootstrap.bundle.min.js, mark the whole content, and copy & paste the content in to your bootstrap.bundle.min.js-file."
                        } -Style "color:$($TextColor)"

                    }
                }

                hr

                div -id "Content" -Class "$($ContinerStyleFluid)" {

                    article -Id "Packages" -Content {

                        h1 {"NPM Packages"} -Style "text-align: center; color:$($HeaderColor)"

                        h2 {"CDNPKG"} -Style "text-align: center; color:$($HeaderColor)"

                        p {
                            "CDNPKG is like a search engine but only for web assets (js, css, fonts etc ...). The primary goal is to help developers to find their web assets more easily for production or development/test."
                        } -Style "color:$($TextColor)"

                        p {
                            "[JQuery](https://www.cdnpkg.com/jquery/file/jquery.min.js/), [Chart Bundle](https://www.cdnpkg.com/Chart.js/file/Chart.bundle.min.js/), [Mermaid](https://www.cdnpkg.com/mermaid?id=87189)"
                        } -Style "color:$($TextColor)"

                        h2 {"UNPKG"} -Style "text-align: center; color:$($HeaderColor)"

                        p {
                            "UNPKG is a fast, global content delivery network for everything on npm."
                        } -Style "color:$($TextColor)"

                        p {
                            "[JQuery](https://unpkg.com/browse/jquery@3.6.3/), [Mermaid](https://unpkg.com/mermaid/)"
                        } -Style "color:$($TextColor)"

                        h2 {"How to update JQuery"} -Style "text-align: center; color:$($HeaderColor)"

                        p {
                            "Open [JQuery](https://www.cdnpkg.com/jquery/file/jquery.min.js/) and find the latest version of JQuery."
                        } -Style "color:$($TextColor)"

                        p {
                            'Click the URL (for example) https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js, mark the whole content, and copy & paste the content in to your jquery.min.js-file.'
                        } -Style "color:$($TextColor)"

                        h2 {"How to update Chart Bundle"} -Style "text-align: center; color:$($HeaderColor)"

                        p {
                            'Open [Chart Bundle](https://www.cdnpkg.com/Chart.js/file/Chart.bundle.min.js/) and find the latest version of Chart Bundle.'
                        } -Style "color:$($TextColor)"

                        p {
                            'Click the URL," mark the whole content, and copy & paste the content in to your Chart.bundle.min.js-file."'
                        } -Style "color:$($TextColor)"
                    }

                }
                #endregion column

            }
            #endregion section
            
        }
        #endregion body

        #region footer
        div -Class "container-fluid" -Style "background-color:#343a40" {
            Footer {

                div -Class "container-fluid" {
                    div -Class "row align-items-center" {
                        div -Class "col-md" {
                            p {
                                a -href "#" -content { "I $([char]9829) PS >" }
                            }
                        }
                        div -Class "col-md" {
                            p {
                                $FooterSummary
                                a -href "https://www.powershellgallery.com/packages/PSHTML" -Target _blank -content { "PSHTML" }
                                ' and '
                                a -href "https://www.powershellgallery.com/packages/Pode" -Target _blank -content { "pode" }
                            }
                        }
                        div -Class "col-md" {
                            p {$((Get-Date).ToString())}
                        } -Style "color:$TextColor"
                    }
                }
        
            }
        }
        #endregion footer

    }
    $Html | Set-Content $OutFile -Encoding utf8
    #endregion html
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
