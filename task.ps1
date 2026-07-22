$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument '-ExecutionPolicy Bypass -NoProfile -File "C:\Windows\gain\DownloadMail.ps1"'

$Trigger = New-ScheduledTaskTrigger `
    -Once `
    -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes 1) `
    -RepetitionDuration (New-TimeSpan -Days 3650)

Register-ScheduledTask `
    -TaskName "DownloadMail" `
    -Action $Action `
    -Trigger $Trigger `
    -RunLevel Highest
