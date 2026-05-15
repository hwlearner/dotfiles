# win-service.ps1 - Service management (start/stop/restart/status)
param(
    [string]$action,
    [string]$name
)

if (-not $action -or -not $name) {
    Write-Output 'Usage: win-service.ps1 -action <start|stop|restart|status> -name <ServiceName>'
    exit 1
}

$svc = Get-Service -Name $name -ErrorAction SilentlyContinue
if (-not $svc) {
    Write-Output "Service '$name' not found"
    exit 1
}

switch ($action) {
    'status'  { $svc | Select-Object Name, Status, StartType | ConvertTo-Json }
    'start'   { $svc | Start-Service -ErrorAction Stop; Write-Output "$name started" }
    'stop'    { $svc | Stop-Service -ErrorAction Stop; Write-Output "$name stopped" }
    'restart' { $svc | Restart-Service -ErrorAction Stop; Write-Output "$name restarted" }
    default   { Write-Output "Unknown action: $action. Use start|stop|restart|status" }
}
