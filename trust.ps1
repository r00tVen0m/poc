$sid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-21-3665801007-1522157668-1663231579")
$dc = Get-ADComputer "DC02"
$acl = Get-Acl "AD:\$($dc.DistinguishedName)"

$identity = $sid
$adRight = [System.DirectoryServices.ActiveDirectoryRights]::ExtendedRight
$type = [System.Security.AccessControl.AccessControlType]::Allow
$guid = New-Object Guid "68B1D179-0D15-4d4f-AB71-46152E79A7BC"

$rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($identity, $adRight, $type, $guid)
$acl.AddAccessRule($rule)
Set-Acl "AD:\$($dc.DistinguishedName)" $acl
