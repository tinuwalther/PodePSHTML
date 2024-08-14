#region header
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
    Script -src $(Join-Path -Path $AssetsPath -ChildPath 'Chartjs\Chart.bundle.min.js')
    # Script -src $(Join-Path -Path $AssetsPath -ChildPath 'Jquery/jquery.min.js')
    # Script -src $(Join-Path -Path $AssetsPath -ChildPath 'mermaid/mermaid.min.js')
    # Script {mermaid.initialize({startOnLoad:true})}

    title "#PSXi $($HeaderTitle)"
    Link -rel icon -type "image/x-icon" -href "/assets/img/favicon.ico"
} 
#endregion header