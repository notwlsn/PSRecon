#Version 1.3   
#PSRecon

$Output = ".\1.log"
$PRINT_FULL = $False

##IP config  
$ipconfig_out = ipconfig /all | findstr /V Subnet
$ips = ([regex]'\d+\.\d+\.\d+\.\d+').Matches($ipconfig_out)
$found_ips = @()
foreach ($i in $ips) {
    if ($found_ips -notcontains $i) {
        $found_ips += $i
    }
}
foreach ($ip in $found_ips) {
    Write-Output "GREP:${compname}:${ip}:ipconfig" | Out-File -Append $Output
}
if ($PRINT_FULL) {
    $ipconfig_out
}

##Net admins
$netadmins_out = net localgroup "Administrators" | where {$_ -and $_ -notmatch "command completed successfully"} | select -skip 4

$found_admins = @()
$netadmins_out | foreach-object {
    if ($found_admins -notcontains $_) {
        $found_admins += $_
    }
}
foreach ($a in $found_admins) {
    Write-Output "GREP:${compname}:${a}:localadmins" | Out-File -Append $Output
}

if ($PRINT_FULL) {
    $netadmins_out
}

## Tasklist 
$tasklist = tasklist /v | findstr /V "===" | findstr /V "User Name"
$found_tasks = @()
$tasklist | ForEach-Object {
    $parts = $_ -split '\s{3,}'
    $together = $parts[0] + ":" + $parts[4]
    if ($found_tasks -notcontains $together) {
        $found_tasks += $together
    }
}
foreach ($task in $found_tasks) {
    Write-Output "GREP:${compname}:${task}:tasklist" | Out-File -Append $Output
}
if ($PRINT_FULL) {
    $tasklist
}

## Route
$routes_out = route print

if ($PRINT_FULL) {
    $routes_out
}

## ARP

$arp_out = arp -a | findstr 'dynamic'
$ips = ([regex]'\d+\.\d+\.\d+\.\d+').Matches($arp_out)
$found_ips = @()
foreach ($i in $ips) {
    if ($found_ips -notcontains $i) {
        $found_ips += $i
    }
}
foreach ($ip in $found_ips) {
    Write-Output "GREP:${compname}:${ip}:arp" | Out-File -Append $Output
}

## Get system name
$name = (Get-WmiObject Win32_ComputerSystem).Name
Write-Output "GREP:${compname}:${name}:systemname" | Out-File -Append $Output

## Get domain
$name = (Get-WmiObject Win32_ComputerSystem).Domain
Write-Output "GREP:${compname}:${name}:domain" | Out-File -Append $Output

## Netstat
$netstat_out = netstat -ano
$ignore_full = @('*:*', 'Address')
$ignore_ip = @('[', '127.0.0.1', '0.0.0.0', '')
$found_ips = @()
$netstat_out | ForEach-Object {
    $ip_port = ($_ -split '\s+' -match '\S')[2]
    $ip = ""
    if ($ip_port -like "*:*") {
        $ip = $ip_port.Split(':')[0]
    }
    if ($found_ips -notcontains $ip_port -and $ignore_full -notcontains $ip_port -and $ignore_ip -notcontains $ip -and -not [string]::IsNullOrWhiteSpace($ip_port)) {          
        $found_ips += $ip_port
    }
}
foreach ($ip in $found_ips) {
    Write-Output "GREP:${compname}:${ip}:netstat" | Out-File -Append $Output
}
if ($PRINT_FULL){
    $netstat_out
}

Write-Output "Complete."