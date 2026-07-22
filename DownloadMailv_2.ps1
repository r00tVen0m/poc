#DownloadMail.ps1

# ==========================
# Exchange Settings
# ==========================
$Username = "ASTERA\emily.davis"
$Password = "Ed#2026!R7vN"
$EwsUrl   = "https://localhost/EWS/Exchange.asmx"

# ==========================
# Paths
# ==========================
$ProcessedFile = "C:\Windows\Temp\processed.txt"
$LocalTempFolder = "C:\Windows\Temp\MailAttachments"

# ==========================
# SMB Session
# ==========================
$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)

Remove-PSDrive -Name HOME -ErrorAction SilentlyContinue
cmd /c "net use \\FILE01\Users$ /delete /y" | Out-Null

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
# Create Download Folder on network share
# ==========================
if (!(Test-Path $DownloadFolder)) {
    New-Item -ItemType Directory -Path $DownloadFolder -Force | Out-Null
}

# ==========================
# Create local temp folder for attachments
# ==========================
if (!(Test-Path $LocalTempFolder)) {
    New-Item -ItemType Directory -Path $LocalTempFolder -Force | Out-Null
}

# ==========================
# Load EWS DLL
# ==========================
Add-Type -Path "C:\EWS\Microsoft.Exchange.WebServices.dll"

# ==========================
# Connect to Exchange
# ==========================
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService
$service.Credentials = New-Object Microsoft.Exchange.WebServices.Data.WebCredentials($Username,$Password)
$service.Url = New-Object Uri($EwsUrl)

# ==========================
# Read processed emails
# ==========================
if (Test-Path $ProcessedFile) {
    $Processed = Get-Content $ProcessedFile
} else {
    $Processed = @()
}

# ==========================
# Open Inbox
# ==========================
$Inbox = [Microsoft.Exchange.WebServices.Data.Folder]::Bind(
    $service,
    [Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox
)

# ==========================
# Get latest 100 emails
# ==========================
$View = New-Object Microsoft.Exchange.WebServices.Data.ItemView(100)
$Items = $service.FindItems($Inbox.Id, $View)

foreach ($Item in $Items.Items) {

    $Item.Load()

    $MessageID = $Item.Id.UniqueId

    # Skip processed emails
    if ($Processed -contains $MessageID) {
        continue
    }

    if ($Item.HasAttachments) {

        foreach ($Attachment in $Item.Attachments) {

            if ($Attachment -is [Microsoft.Exchange.WebServices.Data.FileAttachment]) {

                try {
                    $Attachment.Load()

                    $InvalidChars = [System.IO.Path]::GetInvalidFileNameChars()
                    $CleanName = $Attachment.Name
                    foreach ($Char in $InvalidChars) {
                        $CleanName = $CleanName -replace [regex]::Escape($Char), '_'
                    }

                    # ==========================================
                    # Save locally using original filename
                    # ==========================================

                    $LocalPath = Join-Path $LocalTempFolder $CleanName

                    [System.IO.File]::WriteAllBytes($LocalPath, $Attachment.Content)
                    Write-Host "[+] Saved locally: $LocalPath" -ForegroundColor Green

                    $Extension = [System.IO.Path]::GetExtension($CleanName)
                    $NetworkPath = Join-Path $DownloadFolder ("attachment" + $Extension)

                    Remove-Item -Path $NetworkPath -Force -ErrorAction SilentlyContinue

                    Copy-Item -Path $LocalPath -Destination $NetworkPath -Force
                    Write-Host "[+] Copied to network: $NetworkPath" -ForegroundColor Green

                    Remove-Item -Path $LocalPath -Force -ErrorAction SilentlyContinue
                    Write-Host "[+] Removed local file" -ForegroundColor Green

                }
                catch {
                    Write-Host "[!] Failed to save attachment: $_" -ForegroundColor Red
                    Write-Host "[!] Attachment name: $($Attachment.Name)" -ForegroundColor Red
                }
            }
        }
    }

    Add-Content $ProcessedFile $MessageID
}

# ==========================
# Cleanup
# ==========================
Remove-PSDrive -Name HOME -Force -ErrorAction SilentlyContinue

# Clean up local temp folder if empty
if ((Get-ChildItem $LocalTempFolder -ErrorAction SilentlyContinue).Count -eq 0) {
    Remove-Item -Path $LocalTempFolder -Force -ErrorAction SilentlyContinue
}

Write-Host "[+] Script completed successfully" -ForegroundColor Green
