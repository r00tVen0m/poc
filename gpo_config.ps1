# Import the Active Directory module
Import-Module ActiveDirectory

# Distinguished Name of the Group Policy Objects container
$GPContainerDN = "CN=Policies,CN=System,DC=astera-dev,DC=cg"

# Retrieve the SID of emma.carter
$UserSID = (Get-ADUser "emma.carter").SID

# Get the current ACL of the GPO container
$Acl = Get-Acl "AD:$GPContainerDN"

# Create a new access rule granting CreateChild permission
# CreateChild allows the user to create new objects within the container
$Ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
    $UserSID, `
    "CreateChild", `
    "Allow", `
    [Guid]::Empty, `
    "All"

# Add the new access rule to the ACL
$Acl.AddAccessRule($Ace)

# Apply the updated ACL
Set-Acl "AD:$GPContainerDN" $Acl

Write-Host "[+] Successfully granted CreateChild permission to emma.carter on the Group Policy Objects container." -ForegroundColor Green



----------------

# Import the Active Directory module
Import-Module ActiveDirectory

# Specify the target user and the user who will receive the delegated permission
$TargetUser = "justin.coleman"
$DelegateUser = "emma.carter"

# Retrieve the target user object
$User = Get-ADUser $TargetUser

# Get the Distinguished Name (DN) and SID
$UserDN = $User.DistinguishedName
$UserSID = (Get-ADUser $DelegateUser).SID

# Retrieve the current ACL of the target user object
$Acl = Get-Acl "AD:$UserDN"

# Create an AccessRule for the Reset Password extended right
# Reset Password Extended Right GUID:
# 00299570-246d-11d0-a768-00aa006e0529
$ResetPasswordGUID = [Guid]"00299570-246d-11d0-a768-00aa006e0529"

$Ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
    $UserSID, `
    "ExtendedRight", `
    "Allow", `
    $ResetPasswordGUID, `
    "All"

# Add the new access rule to the ACL
$Acl.AddAccessRule($Ace)

# Apply the updated ACL
Set-Acl "AD:$UserDN" $Acl

Write-Host "[+] Successfully granted Reset Password permission to $DelegateUser on $TargetUser." -ForegroundColor Green

---------------------------------------------------------------------

# Import the Active Directory module
Import-Module ActiveDirectory

# Distinguished Name (DN) of the Default-First-Site-Name site
$SiteDN = "CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=astera-dev,DC=cg"

# Retrieve the SID of justin.coleman
$UserSID = (Get-ADUser "justin.coleman").SID

# GUID of the GP-Link attribute
# GP-Link attribute GUID: f30e3bbe-9ff0-11d1-b603-0000f80367c1
$GPLinkGUID = [Guid]"f30e3bbe-9ff0-11d1-b603-0000f80367c1"

# Retrieve the current ACL of the site object
$Acl = Get-Acl "AD:$SiteDN"

# Create a new AccessRule granting WriteProperty permission
# specifically for the GP-Link attribute
$Ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule `
    $UserSID, `
    "WriteProperty", `
    "Allow", `
    $GPLinkGUID, `
    "All"

# Add the new access rule to the ACL
$Acl.AddAccessRule($Ace)

# Apply the updated ACL
Set-Acl "AD:$SiteDN" $Acl

Write-Host "[+] Successfully granted WriteProperty (GP-Link) permission to justin.coleman on the site object." -ForegroundColor Green
