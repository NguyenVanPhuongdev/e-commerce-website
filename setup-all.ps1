$ErrorActionPreference = "Stop"

# Root paths (adjust if your structure differs)
$root = "X:\DHLSHIPPING"
$backendDir = Join-Path $root "server"    # Change if backend folder is different
$frontendDir = Join-Path $root "frontend"

# Ports
$backendPort = 5000
$frontendPort = 3000

Write-Host "Starting setup..." -ForegroundColor Cyan

# 1) Start backend in new PowerShell window
Start-Process powershell -ArgumentList "-NoExit", "-Command", @"
cd `"$backendDir`"
if (Test-Path package.json) {
  Write-Host 'Installing backend deps...' -ForegroundColor Yellow
  npm install
  Write-Host 'Starting backend (npm run dev)...' -ForegroundColor Green
  npm run dev
} else {
  Write-Host 'No backend/package.json found. Skipping backend.' -ForegroundColor Red
}
"@

# 2) Build and serve frontend in new PowerShell window
Start-Process powershell -ArgumentList "-NoExit", "-Command", @"
cd `"$frontendDir`"
if (Test-Path package.json) {
  Write-Host 'Installing frontend deps...' -ForegroundColor Yellow
  npm install
  Write-Host 'Building frontend...' -ForegroundColor Green
  npm run build
  Write-Host 'Serving dist via npx serve...' -ForegroundColor Green
  npx serve -s dist -l $frontendPort
} else {
  Write-Host 'No frontend/package.json found. Skipping frontend.' -ForegroundColor Red
}
"@

Write-Host "Launched backend (port $backendPort) and frontend (port $frontendPort) in separate windows." -ForegroundColor Cyan
Write-Host "If backend uses npm run dev instead of npm start, edit setup-all.ps1 accordingly." -ForegroundColor Yellow

