#Version 1.0
#PSRecon

$Output = ".\1.log"
Get-NetIPConfiguration | Out-File -Append $Output
Get-NetIPAddress; Get-NetTCPConnection | ? State -eq Established | FT –Autosize | Out-File -Append $Output
Get-NetTCPConnection | Group State, RemotePort | Sort Count | FT Count, Name –Autosize | Out-File -Append $Output
Get-NetAdapterStatistics | Out-File -Append $Output
Get-NetConnectionProfile | Out-File -Append $Output
#Get-ComputerInfo -Property "Windows*" | Out-File -Append $Output # Takes too long to run
Get-DnsClient | Out-File -Append $Output
#Get-EventLog -LogName Security | Out-File -Append $Output # Requires registry access to run


#.\psrecon.ps1 > 1.log #Secondary output method