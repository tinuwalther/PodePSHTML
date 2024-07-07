# PsNetTools
[CmdletBinding()]
Param (
    [String[]]$Destination
)

BeforeDiscovery {
    Import-Module -Name PsNetTools -Force
}

Describe "Test PsNetTools" {

    $TestCase = $Destination
    it "[NEG] Test-PsNetDig to <_> should return true" -Tag Dig -ForEach $TestCase {
        Mock Test-PsNetDig { return [PSCustomObject]@{ Succeeded = $false } }
        (Test-PsNetDig -Destination $PSItem).Succeeded | Should -BeTrue
    }

    it "[POS] Test-PsNetDig to <_> should return a PSCustomObject" -Tag Dig -ForEach $TestCase {
        Mock Test-PsNetDig { return [PSCustomObject]@{ Succeeded = $false } }
        (Test-PsNetDig -Destination $PSItem).Succeeded | Should -BeOfType [PSCustomObject]
    }

    it "[NEG] Test-PsNetPing to <_> should return true" -Tag Ping, NotRun -ForEach $TestCase {
        Mock Test-PsNetPing { return [PSCustomObject]@{ Succeeded = $false } }
        (Test-PsNetPing -Destination $PSItem).Succeeded | Should -BeTrue
    }

    it "[NEG] Test-PsNetTping to <_> should return true" -Tag Ping -ForEach $TestCase {
        Mock Test-PsNetTping { return [PSCustomObject]@{ TcpSucceeded = $false } }
        (Test-PsNetTping -Destination $PSItem -CommonTcpPort HTTPS ).TcpSucceeded | Should -BeTrue
    }

    # Skip this Tests because of the Parameter -Skip is given (can be used in Describe, Context to)
    it "[POS] Test-PsNetUping to <_> should return true" -Tag Ping -Skip -ForEach $TestCase {
        Mock Test-PsNetUping { return [PSCustomObject]@{ UdpSucceeded = $true } }
        (Test-PsNetUping -Destination $PSItem -UdpPort 53 ).UdpSucceeded | Should -BeTrue
    }

    it "[POS] Test-PsNetWping to <_> should return true" -Tag Ping -ForEach $TestCase {
        Mock Test-PsNetWping { return [PSCustomObject]@{ HttpSucceeded = $true } }
        (Test-PsNetWping -Destination $PSItem).HttpSucceeded | Should -BeTrue
    }

}

<#
Invoke-Pester -Path .\ -ExcludeTagFilter NotRun -PassThru | ConvertTo-Json -Depth 1 | Set-Content .\data\Test-PsNetTools.json -Encoding utf8 -Force
Invoke-Pester -Path .\ -ExcludeTagFilter NotRun -OutputFile .\data\Test-PsNetTools.JUnitXml -OutputFormat JUnitXml 
Invoke-Pester -Path .\ -ExcludeTagFilter NotRun -OutputFile .\data\Test-PsNetTools.NUnitXml -OutputFormat NUnitXml 
#>