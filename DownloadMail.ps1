#DownloadMail.ps1
# ==========================
# Exchange Settings
# ==========================
$Username = "ASTERA\emily.davis"
$Password = "Ed#2026!R7vN"
$EwsUrl   = "https://mail.astera.cg/EWS/Exchange.asmx"

# ==========================
# Paths
# ==========================
$DownloadFolder = "\\file01\Users$\emily.davis\Downloads"
$ProcessedFile  = "C:\Windows\Temp\processed.txt"

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
