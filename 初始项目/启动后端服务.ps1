# Start Backend Service
Write-Host "Starting English Tutoring Backend Service..." -ForegroundColor Green

$backendDir = "C:\Users\Lumos\Desktop\初始项目\backend"

# Check if backend directory exists
if (-not (Test-Path $backendDir)) {
    Write-Host "Backend directory not found: $backendDir" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "Backend directory: $backendDir" -ForegroundColor Yellow
Write-Host "Starting Node.js service..." -ForegroundColor Yellow

# Start backend service
Set-Location $backendDir
npm start