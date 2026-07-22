#Run.ps1

Start-Transcript -Path C:\Windows\gain\tasklog.log -Append

# ==========================
# Credentials
# ==========================
$Username = "ASTERA\emily.davis"
$Password = "Ed#2026!R7vN"

$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)

# ==========================
# SMB Session
# ==========================
Remove-PSDrive -Name HOME -ErrorAction SilentlyContinue

New-PSDrive `
    -Name HOME `
    -PSProvider FileSystem `
    -Root "\\FILE01\Users$" `
    -Credential $Credential `
    -Scope Global `
    -ErrorAction Stop | Out-Null

# ==========================
# Get REAL UNC path (not PSDrive path)
# ==========================
$UNCRoot = (Get-PSDrive HOME).Root
$DownloadFolder = Join-Path $UNCRoot "emily.davis\Downloads"

# ==========================
# File paths
# ==========================
$Word = "C:\Program Files (x86)\Microsoft Office\Office14\WINWORD.EXE"
$File = Join-Path $DownloadFolder "attachment.docm"

# ==========================
# Check if file exists
# ==========================
if (Test-Path $File) {
    try {
        $WordProcess = Start-Process -FilePath $Word `
            -ArgumentList "/q", "/m", "`"$File`"" `
            -Credential $Credential `
            -WorkingDirectory "C:\Windows\Tasks" `
            -PassThru `
            -WindowStyle Normal `
            -ErrorAction Stop

        Write-Host "[+] Word process started with PID: $($WordProcess.Id)" -ForegroundColor Green

        # انتظار 60 ثانية
        Start-Sleep -Seconds 60

        if (-not $WordProcess.HasExited) {
            Stop-Process -Id $WordProcess.Id -Force
            Write-Host "[+] Word process stopped (PID: $($WordProcess.Id))" -ForegroundColor Yellow
        }

        if (Test-Path $File) {
            Remove-Item $File -Force
            Write-Host "[+] File deleted: $File" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "[!] Error: $_" -ForegroundColor Red
    }
}
else {
    Write-Host "[!] File not found or access denied: $File" -ForegroundColor Red
}

# ==========================
# Cleanup
# ==========================
Remove-PSDrive -Name HOME -Force -ErrorAction SilentlyContinue

Stop-Transcript
