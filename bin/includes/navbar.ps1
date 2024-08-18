#region <!-- nav -->
# [CmdletBinding()]
# param(
#     [Parameter(Mandatory=$false)]
#     [ValidateNotNullOrEmpty()]
#     [String]$NavbarColor = 'bg-dark navbar-dark',

#     [Parameter(Mandatory=$false)]
#     [ValidateNotNullOrEmpty()]
#     [String]$ContainerStyle  = 'container-fluid',
        
#     [Parameter(Mandatory=$false)]
#     [ValidateNotNullOrEmpty()]
#     [Object]$NavbarWebSiteLinks = [ordered]@{
#         # Anchor        = Navbar menu name
#         "#RebuildByFW"  = 'Re-build by FileWatcher'
#         "#RebuildByAPI" = 'Re-build by API'
#     }

# )

# nav -class "navbar navbar-expand-sm $NavbarColor sticky-top" -content {
    
#     div -class $ContainerStyle {
        
#         a -class "navbar-brand" -href "/" -content {'»HOME'}

#         # <!-- Toggler/collapsibe Button -->
#         button -class "navbar-toggler" -Attributes @{
#             "type"="button"
#             "data-bs-toggle"="collapse"
#             "data-bs-target"="#collapsibleNavbar"
#         } -content {
#             span -class "navbar-toggler-icon"
#         }

#         #region <!-- Navbar links -->
#         div -class "collapse navbar-collapse" -id "collapsibleNavbar" -Content {
#             ul -class "navbar-nav" -content {
#                 $NavbarWebSiteLinks.Keys | ForEach-Object {
#                     li -class "nav-item" -content {
#                         a -class "nav-link" -href $PSitem -Target _blank -content { $NavbarWebSiteLinks[$PSItem] }
#                     }
#                 }
#                 li -class "nav-item" -content {
#                     a -class "nav-link" -href '/help' -content { 'Help' }
#                 }

#             }
#         }
#         #endregion Navbar links
#     }
# }
#endregion nav
