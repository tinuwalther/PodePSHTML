<#
.SYNOPSIS
    Create new web-page

.DESCRIPTION
    Create new pode web-page with PSHTML. Contains the layout with a jumbotron, navbar, body, content, footer.
    
.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlMermaidPage.ps1 -Title 'Mermaid Diagram'

.EXAMPLE
    .\PodePSHTML\bin\New-PshtmlMermaidPage.ps1 -Title 'Mermaid Diagram' -AssetPath '/assets'
#>

[CmdletBinding()]
param (
    #Titel of the new page, will be used for the file name
    [Parameter(Mandatory=$true)]
    [String]$Title,

    #Requested by API or FileWatcher
    [Parameter(Mandatory=$true)]
    [String]$Request,

    #TSQL Statement
    [Parameter(Mandatory=$false)]
    [String]$TsqlQuery,

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
        'https://mermaid.js.org/syntax/classDiagram.html' = 'Mermaid'
    }

    $SQLiteDbRoot = $($PSScriptRoot).Replace('bin','db')
    $SQLiteDbPath = Join-Path $SQLiteDbRoot -ChildPath 'psxi.db'
    $RelationShip = '--'
    
    if([String]::IsNullOrEmpty($TsqlQuery)){
        $SqliteQuery = 'SELECT * FROM "classic_ESXiHosts" ORDER BY HostName'
    }else{
        $SqliteQuery = $TsqlQuery
    }

    if(Test-Path $SQLiteDbPath){
        $SqliteConnection = Open-MySQLiteDB -Path $SQLiteDbPath
        if([String]::IsNullOrEmpty($SqliteConnection)){
            # p { 'Could not connect to SQLite database {0}' -f $SQLiteDbPath }
        }else{
            # $SqliteQuery = 'SELECT * FROM "classic_ESXiHosts" ORDER BY HostName'
            $SQLiteData = Invoke-MySQLiteQuery -Path $SQLiteDbPath -Query $SqliteQuery
        }
    }else{
        # p { 'Could not find {0}' -f $SQLiteDbPath }
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
                                a -class "nav-link" -href $PSitem -Target _blank -content { $NavbarWebSiteLinks[$PSItem] }
                            }
                        }
                        if(-not([String]::IsNullOrEmpty($SQLiteData))){
                            $SQLiteData | Group-Object vCenterServer | Select-Object -ExpandProperty Name | ForEach-Object {
                                $vCenter = $($_).Split('.')[0]
                                if(-not([String]::IsNullOrEmpty($vCenter))){
                                    li -class "nav-item" -content {
                                        a -class "nav-link" -href "#$($vCenter)" -content { $($vCenter) }
                                    }
                                }
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
            Script -src $(Join-Path -Path $AssetsPath -ChildPath 'mermaid/mermaid.min.js')
            Script {mermaid.initialize({startOnLoad:true})}

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
                    h1 {'VMware ESXi Host Diagram'} -Style "color:$($HeaderColor); text-align: center"
                    p {'Based on {0}' -f $SqliteQuery} -Style "color:$($TextColor); text-align: center"
                    p { 'VC# = vCenter, C# = Cluster' } -Style "color:$($TextColor); text-align: center"
                }

                div -id "Content" -Class "$($ContainerStyle)" {
                    article -Id "SQLite" -Content {
                        if(-not([String]::IsNullOrEmpty($SQLiteData))){
                            #region vCenter
                            $SQLiteData | Group-Object vCenterServer | Select-Object -ExpandProperty Name | ForEach-Object {
                                
                                $vcNo ++; $vCenterFullname = $PSItem; $vCenterName = $($PSItem).Split('.')[0]

                                # -Style "background-color:#53ec53"
                                div -id "Content" -Class "$($ContinerStyle)" {

                                    article -id "mermaid" -Content {
                                        
                                        if(-not([String]::IsNullOrEmpty($vCenterName))){

                                            h2 -id $vCenterName {'vCenter {0}' -f $vCenterName} -Style "color:#198754; text-align: center"

                                            p {'Class-diagram for the vCenter Server {0}' -f $vCenterName} -Style "color:$($TextColor); text-align: center"
                                            
                                            #region mermaid
                                            div -Class "mermaid" -Style "text-align: center" {
                        
                                                "classDiagram`n"
                                                
                                                #region Notes on vCenter
                                                "class VC$($vcNo)_$($vCenterName){ VC$($vcNo) is the vCenter $($vCenterName)() }`n"
                                                #endregion Notes on vCenter

                                                #region Group Cluster
                                                $SQLiteData | Where-Object vCenterServer -match $vCenterFullname | Group-Object Cluster | Select-Object -ExpandProperty Name | ForEach-Object {

                                                    if(-not([String]::IsNullOrEmpty($PSItem))){

                                                        $ClusterNo ++; $RootCluster = $PSItem
                                                        
                                                        # Print out vCenter --> Cluster
                                                        "VC$($vcNo)_$($vCenterName) $($RelationShip) VC$($vcNo)C$($ClusterNo)_$($RootCluster)`n"

                                                        "VC$($vcNo)_$($vCenterName) : + $($RootCluster)`n"
                                                            
                                                        #region Notes on Cluster
                                                        "class VC$($vcNo)C$($ClusterNo)_$($RootCluster){ C$($ClusterNo) is the Cluster $($RootCluster)() }`n"
                                                        #endregion Notes on Cluster

                                                        #region Group PhysicalLocation
                                                        $SQLiteData | Where-Object vCenterServer -match $vCenterFullname | Where-Object Cluster -match $RootCluster | Group-Object PhysicalLocation | Select-Object -ExpandProperty Name | ForEach-Object {

                                                            $PhysicalLocation = $_
                                                            $ObjectCount = $SQLiteData | Where-Object vCenterServer -match $vCenterFullname | Where-Object Cluster -match $RootCluster | Where-Object PhysicalLocation -match $PhysicalLocation | Select-Object -ExpandProperty HostName

                                                            #region Notes on PhysicalLocation
                                                            "class VC$($vcNo)C$($ClusterNo)_$($PhysicalLocation){ Data center $($PhysicalLocation)() }`n"
                                                            #endregion Notes on PhysicalLocation

                                                            "VC$($vcNo)C$($ClusterNo)_$($RootCluster) : - $($PhysicalLocation), $($ObjectCount.count) ESXi Hosts`n"

                                                            "VC$($vcNo)C$($ClusterNo)_$($RootCluster) $($RelationShip) VC$($vcNo)C$($ClusterNo)_$($PhysicalLocation)`n"

                                                            #region Group HostName
                                                            $SQLiteData | Where-Object vCenterServer -match $vCenterFullname | Where-Object Cluster -match $RootCluster | Where-Object PhysicalLocation -match $PhysicalLocation | Group-Object HostName | Select-Object -ExpandProperty Name | ForEach-Object {

                                                                $HostObject = $SQLiteData | Where-Object HostName -match $($PSItem)
                                                                $ESXiHost   = $($HostObject.HostName).Split('.')[0]
                                                                $HostNotes = $SQLiteData | Where-Object HostName -like $($HostObject.HostName) | Select-Object -ExpandProperty Notes

                                                                #region Notes on ESXiHost
                                                                if($HostNotes){
                                                                    "class VC$($vcNo)C$($ClusterNo)_$($PhysicalLocation){ $($ESXiHost)($HostNotes) }`n"
                                                                }
                                                                #endregion Notes on ESXiHost

                                                                if($HostObject.ConnectionState -eq 'Connected'){
                                                                    $prefix = '+'
                                                                }elseif($HostObject.ConnectionState -match 'New'){
                                                                    $prefix = 'o'
                                                                }else{
                                                                    $prefix = '-'
                                                                }
                
                                                                "VC$($vcNo)C$($ClusterNo)_$($PhysicalLocation) : $($prefix) $($ESXiHost), ESXi $($HostObject.Version)`n"
                
                                                            }
                                                            #endregion Group HostName

                                                        }
                                                        #endregion Group PhysicalLocation
                                                    }
                                                }
                                                #endregion Group Cluster

                                            }
                                            #endregion mermaid
                                        }
                                    }

                                }

                                hr
                            }
                            #endregion vCenter
                        }else{
                            p { 'Could not connect to SQLite database {0}' -f $SQLiteDbPath }
                        }
                    }
                } -Style "color:#000" #"color:#d0d0d0"
                #endregion content
                
            }

            pre {
                'Re-builds the page: I ♥ PS > Invoke-WebRequest -Uri http://localhost:8080/api/mermaid -Method Post -Body ''SELECT * FROM "cloud_ESXiHosts" ORDER BY HostName'''
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
