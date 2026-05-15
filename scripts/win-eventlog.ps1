# win-eventlog.ps1 - Tail Windows event log
param(
    [string]$channel = 'System',
    [int]$tail = 20
)

try {
    Get-WinEvent -LogName $channel -MaxEvents $tail -ErrorAction Stop |
        ForEach-Object {
            $msg = $_.Message -replace '\s+', ' '
            @{
                time    = $_.TimeCreated.ToString('o')
                level   = $_.LevelDisplayName
                source  = $_.ProviderName
                id      = $_.Id
                message = if ($msg.Length -gt 200) { $msg.Substring(0, 200) + '...' } else { $msg }
            }
        } |
        ConvertTo-Json -Depth 2
}
catch {
    Write-Output "Failed to read log '$channel': $_"
}
