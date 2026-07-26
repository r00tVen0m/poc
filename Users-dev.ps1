Import-Module ActiveDirectory

# ============================================================================
# Active Directory Configuration
# ============================================================================

$UsersOU = "OU=Users,OU=CORP-DEV,DC=astera-dev,DC=cg"
$DefaultGroup = "ASTERA-DEV Users"

# ============================================================================
# Users
# ============================================================================

$Users = @(
    @{First="Aaron";Last="Mitchell";Sam="aaron.mitchell";Department="IT";Group="IT Support";Password="Am#2026!K8qL"}
    @{First="Rachel";Last="Bennett";Sam="rachel.bennett";Department="Helpdesk";Group="Helpdesk";Password="Rb#2026!M4xP"}
    @{First="Justin";Last="Coleman";Sam="justin.coleman";Department="DevOps";Group="DevOps Engineers";Password="Jc#2026!T7vN"}
    @{First="Megan";Last="Foster";Sam="megan.foster";Department="Development";Group="Senior Developers";Password="Mf#2026!R2hK"}
    @{First="Eric";Last="Sullivan";Sam="eric.sullivan";Department="Development";Group="Senior Developers";Password="Es#2026!P9mW"}
    @{First="Natalie";Last="Griffin";Sam="natalie.griffin";Department="Release";Group="Release Managers";Password="Ng#2026!Y5cQ"}
    @{First="Tyler";Last="Brooks";Sam="tyler.brooks";Department="IT";Group="File Share Admins";Password="Tb#2026!L3zX"}
    @{First="Lucas";Last="Reed";Sam="lucas.reed";Department="IT";Group="IT Support";Password="Lr#2026!D6nB"}
    @{First="Emma";Last="Carter";Sam="emma.carter";Department="Helpdesk";Group="Helpdesk";Password="Ec#2026!S4wJ"}
    @{First="Noah";Last="Hayes";Sam="noah.hayes";Department="DevOps";Group="DevOps Engineers";Password="Nh#2026!F9tQ"}
    @{First="Grace";Last="Morgan";Sam="grace.morgan";Department="Development";Group="Senior Developers";Password="Gm#2026!A7pL"}
    @{First="Ethan";Last="Ward";Sam="ethan.ward";Department="Release";Group="Release Managers";Password="Ew#2026!V5kR"}
    @{First="Olivia";Last="Price";Sam="olivia.price";Department="IT";Group="IT Support";Password="Op#2026!H8xN"}
    @{First="Daniel";Last="Cook";Sam="daniel.cook";Department="IT";Group="File Share Admins";Password="Dc#2026!M3qT"}
    @{First="Sophia";Last="Parker";Sam="sophia.parker";Department="DevOps";Group="DevOps Engineers";Password="Sp#2026!Z7cW"}
    @{First="Nathan";Last="Ross";Sam="nathan.ross";Department="Development";Group="Senior Developers";Password="Nr#2026!B2yK"}
    @{First="Lily";Last="Turner";Sam="lily.turner";Department="Helpdesk";Group="Helpdesk";Password="Lt#2026!X6mP"}
)

# ============================================================================
# Create Users
# ============================================================================

foreach ($User in $Users)
{
    $DisplayName = "$($User.First) $($User.Last)"

    if (Get-ADUser -Filter "SamAccountName -eq '$($User.Sam)'" -ErrorAction SilentlyContinue)
    {
        Write-Host "[!] User already exists: $($User.Sam)" -ForegroundColor Yellow
        continue
    }

    $SecurePassword = ConvertTo-SecureString $User.Password -AsPlainText -Force

    New-ADUser `
        -Name $DisplayName `
        -DisplayName $DisplayName `
        -GivenName $User.First `
        -Surname $User.Last `
        -SamAccountName $User.Sam `
        -UserPrincipalName "$($User.Sam)@astera-dev.cg" `
        -Department $User.Department `
        -Path $UsersOU `
        -AccountPassword $SecurePassword `
        -Enabled $true `
        -PasswordNeverExpires $true `
        -ChangePasswordAtLogon $false

    # Add to default users group
    Add-ADGroupMember -Identity $DefaultGroup -Members $User.Sam

    # Add to department/security group
    Add-ADGroupMember -Identity $User.Group -Members $User.Sam

    Write-Host "[+] Created: $DisplayName" -ForegroundColor Green
    Write-Host "    Username : $($User.Sam)"
    Write-Host "    Password : $($User.Password)"
    Write-Host "    Group    : $($User.Group)"
    Write-Host ""
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Users created successfully!" -ForegroundColor Green
Write-Host "OU            : $UsersOU"
Write-Host "Default Group : $DefaultGroup"
Write-Host "Password Never Expires : Enabled"
Write-Host "=========================================" -ForegroundColor Cyan
