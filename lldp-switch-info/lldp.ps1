$tshark = "C:\Program Files\Wireshark\tshark.exe"
$iface = "Ethernet"
$duration = 30

# Get own IP address
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
$ip4 = ""
$ip6 = ""
$mac = ""
$port = ""
$vlan = ""
$model = ""

foreach ($line in $output) {

    if ($line -match "System Name:\s+(.*)") {
        $switch = $matches[1].Trim()
    }

    if ($line -match "Port Description:\s+(.*)") {
        $port = $matches[1].Trim()
    }

    if ($line -match "Port VLAN Identifier:\s+(\d+)") {
        $vlan = $matches[1]
    }

    # Management Address detection
    if ($line -match "Management Address:\s+(.+)") {
        $addr = $matches[1].Trim()

        if ($addr -match "^(\d{1,3}\.){3}\d{1,3}$") {
            $ip4 = $addr
        }
        elseif ($addr -match "^[0-9a-fA-F:]+$" -and $addr -match ":") {
            $ip6 = $addr
        }
        elseif ($addr -match "^[0-9a-fA-F]{12}$") {
            $mac = ($addr -split '(.{2})' | Where-Object {$_}) -join ':'
        }
    }

    # Model parsing
    if ($line -match "System Description:\s+(.*)") {
        $desc = $matches[1]

        if ($desc -match "^(.*?)\\r\\n") {
            $model = $matches[1].Trim()
        }
        else {
            $model = $desc.Trim()
        }
    }

    # If everything is found
    if ($switch -and $port -and $vlan) {

        # Model fallback
        if (-not $model) {
            if ($switch -match "HUAWEI") {
                $model = "Huawei (model onbekend)"
            }
            elseif ($switch -match "Cisco") {
                $model = "Cisco (model onbekend)"
            }
            elseif ($switch -match "HP|Aruba") {
                $model = "HPE/Aruba (model onbekend)"
            }
            else {
                $model = "Onbekend"
            }
        }

        # MGMT dynamic
        $mgmtParts = @()
        if ($mac) { $mgmtParts += "MAC: $mac" }
        if ($ip4) { $mgmtParts += "IPv4: $ip4" }
        if ($ip6) { $mgmtParts += "IPv6: $ip6" }

        $mgmt = $mgmtParts -join "  "

        $results += [PSCustomObject]@{
            SwitchName = $switch
            SwitchMGMT = $mgmt
            Model      = $model
            Port       = $port
            VLAN_ID    = [int]$vlan
        }

        # reset
        $switch = ""
        $ip4 = ""
        $ip6 = ""
        $mac = ""
        $port = ""
        $vlan = ""
        $model = ""
    }
}

# Unique
$results = $results | Sort-Object SwitchName -Unique

# 🔹 Nice list output
$labelWidth = 14

foreach ($r in $results) {

    "{0,-$labelWidth} {1}" -f "SwitchName:", $r.SwitchName
    "{0,-$labelWidth} {1}" -f "SwitchMGMT:", $r.SwitchMGMT
    "{0,-$labelWidth} {1}" -f "Model:",      $r.Model
    "{0,-$labelWidth} {1}" -f "Port:",       $r.Port
    "{0,-$labelWidth} {1}" -f "VLAN_ID:",    $r.VLAN_ID

    Write-Host ""
}
