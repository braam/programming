$tshark = "C:\Program Files\Wireshark\tshark.exe"
$iface = "Ethernet"
$duration = 30

# Eigen IP ophalen
$myIP = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias $iface |
         Where-Object {$_.IPAddress -notlike "169.*"} |
         Select-Object -First 1 -ExpandProperty IPAddress)

Write-Host ""
Write-Host "Eigen IP: $myIP"
Write-Host "Scanning LLDP op '$iface' gedurende $duration seconden..."
Write-Host ""

# Capture
$output = & "$tshark" -i $iface -a duration:$duration -Y "lldp" -V 2>$null

# Vars
$results = @()
$switch = ""
$ip = ""
$port = ""
$vlan = ""

foreach ($line in $output) {

    if ($line -match "System Name:\s+(.*)") {
        $switch = $matches[1].Trim()
    }

    if ($line -match "Management Address:\s+([0-9\.]+)") {
        $ip = $matches[1]
    }

    if ($line -match "Port Description:\s+(.*)") {
        $port = $matches[1].Trim()
    }

    if ($line -match "Port VLAN Identifier:\s+(\d+)") {
        $vlan = $matches[1]
    }

    # Als alles gevonden is
    if ($switch -and $port -and $vlan) {

        $results += [PSCustomObject]@{
            SwitchName = $switch
            IP         = $ip
            Port       = $port
            VLAN_ID    = [int]$vlan
        }

        # reset
        $switch = ""
        $ip = ""
        $port = ""
        $vlan = ""
    }
}

# Uniek
$results = $results | Sort-Object SwitchName -Unique

# Header
"{0,-18} {1,-15} {2,-40} {3,8}" -f "SwitchName","SwitchIP","Port","VLAN_ID"
"{0,-18} {1,-15} {2,-40} {3,8}" -f "----------","--------","----","-------"

# Data
foreach ($r in $results) {
    "{0,-18} {1,-15} {2,-40} {3,8}" -f $r.SwitchName, $r.IP, $r.Port, $r.VLAN_ID
}
