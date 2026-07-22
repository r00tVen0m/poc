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

$DownloadFolder = "HOME:\emily.davis\Downloads"

# ==========================
# Create Download Folder
# ==========================
if (!(Test-Path $DownloadFolder)) {
    New-Item -ItemType Directory -Path $DownloadFolder -Force | Out-Null
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

                $Attachment.Load()

                $Destination = Join-Path $DownloadFolder "attachment.docm"

                [System.IO.File]::WriteAllBytes(
                    $Destination,
                    $Attachment.Content
                )

                Write-Host "[+] Saved attachment.docm"
            }
        }
    }

    Add-Content $ProcessedFile $MessageID
}

# ==========================
# Cleanup
# ==========================
Remove-PSDrive -Name HOME -Force -ErrorAction SilentlyContinue
