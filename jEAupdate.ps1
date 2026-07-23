# =====================================================================
# Configure JEA Endpoint for ASTERA\andrew.allen (Low Privilege)
# =====================================================================
# Run as Administrator
Enable-PSRemoting -Force

$ModuleName = "MailJEA"
$ModulePath = "C:\Program Files\WindowsPowerShell\Modules\$ModuleName"
$RolePath   = Join-Path $ModulePath "RoleCapabilities"
$ConfigPath = "C:\JEAConfig"

# Create directories
New-Item -ItemType Directory -Path $RolePath -Force | Out-Null
New-Item -ItemType Directory -Path $ConfigPath -Force | Out-Null

# Create Role Capability
New-PSRoleCapabilityFile `
    -Path "$RolePath\MailRole.psrc" `
    -VisibleCmdlets @(
        'Get-Command',
        'Get-Help',
        'Get-Process',
        'Get-Service',
        'Get-ChildItem',
        'Get-Item',
        'Get-Location'
    ) `
    -VisibleExternalCommands @(
        'C:\Windows\System32\ipconfig.exe',
        'C:\Windows\System32\ping.exe'
    ) `
    -VisibleFunctions @() `
    -VisibleAliases @()

# Create module manifest
New-ModuleManifest `
    -Path "$ModulePath\MailJEA.psd1" `
    -RootModule "" `
    -ModuleVersion "1.0"

# إنشاء مجموعة محلية منخفضة الصلاحيات بدل استخدام Administrators
if (-not (Get-LocalGroup -Name "JEA-MailOperators" -ErrorAction SilentlyContinue)) {
    New-LocalGroup -Name "JEA-MailOperators" -Description "Low privilege group for Mail JEA virtual accounts"
}

# Create Session Configuration
New-PSSessionConfigurationFile `
    -Path "$ConfigPath\MailJEA.pssc" `
    -SessionType RestrictedRemoteServer `
    -LanguageMode ConstrainedLanguage `
    -RunAsVirtualAccountGroups @('JEA-MailOperators') `
    -RoleDefinitions @{
        'ASTERA\andrew.allen' = @{
            RoleCapabilities = 'MailRole'
        }
    }

# Register Endpoint
if (Get-PSSessionConfiguration -Name MailJEA -ErrorAction SilentlyContinue) {
    Unregister-PSSessionConfiguration -Name MailJEA -Force
}
Register-PSSessionConfiguration `
    -Name MailJEA `
    -Path "$ConfigPath\MailJEA.pssc" `
    -Force

Restart-Service WinRM

Write-Host ""
Write-Host "JEA Endpoint created successfully with LOW privilege virtual account."
Write-Host ""
Write-Host "Connect using:"
Write-Host "Enter-PSSession -ComputerName <SERVER> -ConfigurationName MailJEA -Credential ASTERA\andrew.allen"
