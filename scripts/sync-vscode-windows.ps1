[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
  [string]$VSCodeUserDir = (Join-Path $env:APPDATA "Code\User"),
  [string]$NeovimPath = "C:\Program Files\Neovim\bin\nvim.exe",
  [string]$CangjieHome = "",
  [string]$CodeCommand = "code",
  [switch]$InstallExtensions
)

$ErrorActionPreference = "Stop"

function Set-JsonProperty {
  param(
    [Parameter(Mandatory = $true)][object]$Object,
    [Parameter(Mandatory = $true)][string]$Name,
    [Parameter(Mandatory = $true)]$Value
  )

  $property = $Object.PSObject.Properties[$Name]
  if ($null -eq $property) {
    $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
    return
  }

  $property.Value = $Value
}

function Remove-JsonProperty {
  param(
    [Parameter(Mandatory = $true)][object]$Object,
    [Parameter(Mandatory = $true)][string]$Name
  )

  [void]$Object.PSObject.Properties.Remove($Name)
}

function Ensure-Directory {
  param([Parameter(Mandatory = $true)][string]$Path)

  if (Test-Path -LiteralPath $Path) {
    return
  }

  if ($PSCmdlet.ShouldProcess($Path, "Create directory")) {
    [void](New-Item -ItemType Directory -Path $Path -Force)
  }
}

function Copy-ManagedFile {
  param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Destination
  )

  Ensure-Directory -Path (Split-Path -Parent $Destination)
  if ($PSCmdlet.ShouldProcess($Destination, "Copy $(Split-Path -Leaf $Source)")) {
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
  }
}

function Write-JsonFile {
  param(
    [Parameter(Mandatory = $true)][object]$Object,
    [Parameter(Mandatory = $true)][string]$Destination
  )

  Ensure-Directory -Path (Split-Path -Parent $Destination)
  $json = $Object | ConvertTo-Json -Depth 32
  if ($PSCmdlet.ShouldProcess($Destination, "Write JSON")) {
    Set-Content -LiteralPath $Destination -Value ($json + [Environment]::NewLine) -Encoding UTF8
  }
}

function Resolve-CodeCommand {
  param([Parameter(Mandatory = $true)][string]$CommandName)

  $command = Get-Command $CommandName -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  $candidateRoots = @()
  if (-not [string]::IsNullOrWhiteSpace($env:LOCALAPPDATA)) {
    $candidateRoots += Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code"
  }
  if (-not [string]::IsNullOrWhiteSpace($env:ProgramFiles)) {
    $candidateRoots += Join-Path $env:ProgramFiles "Microsoft VS Code"
  }
  if (-not [string]::IsNullOrWhiteSpace(${env:ProgramFiles(x86)})) {
    $candidateRoots += Join-Path ${env:ProgramFiles(x86)} "Microsoft VS Code"
  }

  $candidates = $candidateRoots | ForEach-Object {
    Join-Path $_ "bin\code.cmd"
  } | Where-Object {
    Test-Path -LiteralPath $_
  }

  if ($candidates.Count -gt 0) {
    return $candidates[0]
  }

  return $null
}

$RepoRoot = (Resolve-Path $RepoRoot).Path
$userHome = [Environment]::GetFolderPath("UserProfile")
$nvimVscodeDir = Join-Path $userHome ".config\nvim-vscode"
$nvimVscodeInit = Join-Path $nvimVscodeDir "init.lua"
$markdownlintTarget = Join-Path $userHome ".markdownlint.yaml"

$settingsSource = Join-Path $RepoRoot "vscode\User\settings.json"
$keybindingsSource = Join-Path $RepoRoot "vscode\User\keybindings.json"
$localeSource = Join-Path $RepoRoot "vscode\User\locale.json"
$extensionsSource = Join-Path $RepoRoot "vscode\extensions.txt"
$nvimInitSource = Join-Path $RepoRoot "nvim-vscode\init.lua"
$markdownlintSource = Join-Path $RepoRoot ".markdownlint.yaml"

$requiredFiles = @(
  $settingsSource,
  $keybindingsSource,
  $localeSource,
  $extensionsSource,
  $nvimInitSource,
  $markdownlintSource
)

foreach ($file in $requiredFiles) {
  if (-not (Test-Path -LiteralPath $file)) {
    throw "Missing required file: $file"
  }
}

Write-Host "Syncing VS Code config from $RepoRoot"

Copy-ManagedFile -Source $keybindingsSource -Destination (Join-Path $VSCodeUserDir "keybindings.json")
Copy-ManagedFile -Source $localeSource -Destination (Join-Path $VSCodeUserDir "locale.json")
Copy-ManagedFile -Source $nvimInitSource -Destination $nvimVscodeInit
Copy-ManagedFile -Source $markdownlintSource -Destination $markdownlintTarget

$settings = Get-Content -LiteralPath $settingsSource -Raw | ConvertFrom-Json
Set-JsonProperty -Object $settings -Name "markdownlint.configFile" -Value $markdownlintTarget
Set-JsonProperty -Object $settings -Name "vscode-neovim.neovimExecutablePaths.win32" -Value $NeovimPath
Set-JsonProperty -Object $settings -Name "vscode-neovim.neovimInitVimPaths.win32" -Value $nvimVscodeInit

$defaultCangjieHome = Join-Path $userHome "Developer\cangjie\current"
if ([string]::IsNullOrWhiteSpace($CangjieHome)) {
  if (Test-Path -LiteralPath $defaultCangjieHome) {
    $CangjieHome = $defaultCangjieHome
  }
}

if ([string]::IsNullOrWhiteSpace($CangjieHome)) {
  Remove-JsonProperty -Object $settings -Name "CangjieSdkPath.CJNativeBackend"
  Remove-JsonProperty -Object $settings -Name "CangjieSdk.Option"
  Write-Host "Cangjie SDK not detected, skipped related VS Code settings."
} else {
  Set-JsonProperty -Object $settings -Name "CangjieSdkPath.CJNativeBackend" -Value $CangjieHome
  Set-JsonProperty -Object $settings -Name "CangjieSdk.Option" -Value "CJNative"
  if (-not (Test-Path -LiteralPath $CangjieHome)) {
    Write-Warning "Configured Cangjie SDK path does not exist yet: $CangjieHome"
  }
}

if (-not (Test-Path -LiteralPath $NeovimPath)) {
  Write-Warning "Neovim executable not found at $NeovimPath"
}

Write-JsonFile -Object $settings -Destination (Join-Path $VSCodeUserDir "settings.json")

if ($InstallExtensions) {
  $resolvedCodeCommand = Resolve-CodeCommand -CommandName $CodeCommand
  if ($null -eq $resolvedCodeCommand) {
    Write-Warning "VS Code CLI not found, skipped extension install. Add 'code' to PATH or pass -CodeCommand."
  } else {
    $extensions = Get-Content -LiteralPath $extensionsSource | Where-Object {
      -not [string]::IsNullOrWhiteSpace($_) -and -not $_.TrimStart().StartsWith("#")
    }

    foreach ($extension in $extensions) {
      $trimmed = $extension.Trim()
      if ($PSCmdlet.ShouldProcess($trimmed, "Install VS Code extension")) {
        Write-Host "Installing extension $trimmed"
        & $resolvedCodeCommand --install-extension $trimmed --force | Out-Host
      }
    }
  }
}

Write-Host "VS Code sync completed."
