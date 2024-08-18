# To includes code from external script for --> footer:
# . (Join-Path -Path $PSScriptRoot -ChildPath 'includes/footer.ps1')

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
                    p {"Created at $(Get-Date -f 'yyyy-MM-dd HH:mm:ss')"}
                } -Style "color:$TextColor"
            }
        }

    }
}
#endregion footer

