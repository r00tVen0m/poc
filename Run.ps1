$Word = "C:\Program Files\Microsoft Office\Office14\WINWORD.EXE"
$File = "\\FILE01\Users$\emily.davis\Downloads\attachment.docm"

if (Test-Path $File) {

    $WordProcess = Start-Process -FilePath $Word -ArgumentList "`"$File`"" -PassThru


    Start-Sleep -Seconds 180

    if (-not $WordProcess.HasExited) {
        Stop-Process -Id $WordProcess.Id -Force
    }

    if (Test-Path $File) {
        Remove-Item $File -Force
    }
}
