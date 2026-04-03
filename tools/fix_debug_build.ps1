param(
    [switch]$SkipBuild,
    [switch]$SkipPubGet,
    [switch]$SkipClean
)

$ErrorActionPreference = 'Stop'

function Step($message) {
    Write-Host "`n==> $message" -ForegroundColor Cyan
}

function Warn($message) {
    Write-Host "[WARN] $message" -ForegroundColor Yellow
}

function Info($message) {
    Write-Host "[INFO] $message" -ForegroundColor Gray
}

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $projectRoot

Step "Stopping processes that commonly lock Android artifacts"
$processes = @('java', 'javaw', 'gradle', 'kotlin', 'adb')
foreach ($name in $processes) {
    try {
        Get-Process -Name $name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction Stop
        Info "Stopped process: $name"
    }
    catch {
        Info "No running process to stop: $name"
    }
}

Start-Sleep -Seconds 2

Step "Removing stale build lock-prone directories"
$pathsToRemove = @(
    (Join-Path $projectRoot "build\app\intermediates\compile_and_runtime_not_namespaced_r_class_jar"),
    (Join-Path $projectRoot ".gradle")
)

foreach ($path in $pathsToRemove) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        Info "Removed: $path"
    }
    else {
        Info "Not found, skipped: $path"
    }
}

if (-not $SkipClean) {
    Step "Running flutter clean"
    flutter clean
}
else {
    Warn "Skipping flutter clean"
}

if (-not $SkipPubGet) {
    Step "Running flutter pub get"
    flutter pub get
}
else {
    Warn "Skipping flutter pub get"
}

if (-not $SkipBuild) {
    Step "Running flutter build apk --debug"
    flutter build apk --debug
}
else {
    Warn "Skipping debug build"
}

Step "Done"
Write-Host "If build still fails with file lock, close Android Studio and rerun this script." -ForegroundColor Green
