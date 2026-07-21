$Word = "C:\Program Files\Microsoft Office\Office14\WINWORD.EXE"
$File = "\\FILE01\Users$\emily.davis\Downloads\attachment.docm"
$Username = "ASTERA\emily.davis"
$Password = "Ed#2026!R7vN"

$SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($Username, $SecurePassword)

if (Test-Path $File) {
    $WordProcess = Start-Process -FilePath $Word `
        -ArgumentList "`"$File`"" `
        -Credential $Credential `
        -PassThru `
        -WindowStyle Normal

    Start-Sleep -Seconds 180

    if (-not $WordProcess.HasExited) {
        Stop-Process -Id $WordProcess.Id -Force
    }

    # حذف الملف
    if (Test-Path $File) {
        Remove-Item $File -Force
    }
}
