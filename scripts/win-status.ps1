# win-status.ps1 - Windows system status report
param([switch]$json)

$info = @{
    hostname     = $env:COMPUTERNAME
    uptime       = (Get-CimInstance Win32_OperatingSystem).LastBootUpTime.ToString('o')
    cpu_usage    = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    memory       = @{
        total_gb = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
        free_gb  = [math]::Round((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB, 1)
    }
    disks        = Get-CimInstance Win32_LogicalDisk |
                   Where-Object DriveType -eq 3 |
                   ForEach-Object {
                       @{
                           drive   = $_.DeviceID
                           size_gb = [math]::Round($_.Size / 1GB, 1)
                           free_gb = [math]::Round($_.FreeSpace / 1GB, 1)
                       }
                   }
    top_processes = Get-Process |
                    Sort-Object WorkingSet64 -Descending |
                    Select-Object -First 5 |
                    ForEach-Object {
                        @{
                            name   = $_.ProcessName
                            pid    = $_.Id
                            mem_mb = [math]::Round($_.WorkingSet64 / 1MB, 1)
                        }
                    }
}

$info | ConvertTo-Json -Depth 3
