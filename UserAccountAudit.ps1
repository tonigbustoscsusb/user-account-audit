<#
.SYNOPSIS
    User Account Audit Tool for Active Directory or Local Machine

.DESCRIPTION
    This script audits user accounts by listing username, status, last logon, 
    password last set, and group membership, exporting results to CSV.

.AUTHOR
    Toni Bustos

.VERSION
    1.0
#>

# Import Active Directory module (required if running on a domain)
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

# Define output file
$outputFile = "$env:USERPROFILE\Desktop\User_Account_Audit_Report.csv"

# Check if machine is domain joined
try {
    $domainCheck = (Get-WmiObject Win32_ComputerSystem).PartOfDomain
} catch {
    Write-Host "Error checking domain status: $_"
    exit
}

if ($domainCheck) {
    Write-Host "Running Active Directory User Audit..."
    $users = Get-ADUser -Filter * -Properties Enabled, LastLogonDate, PasswordLastSet, MemberOf | 
        Select-Object Name, Enabled, LastLogonDate, PasswordLastSet, @{Name='Groups';Expression={[string]::Join(', ', ($_ | Get-ADPrincipalGroupMembership | Select-Object -ExpandProperty Name))}}
}
else {
    Write-Host "Running Local Machine User Audit..."
    $users = Get-LocalUser | 
        Select-Object Name, Enabled, LastLogon, PasswordLastSet, @{Name='Groups';Expression={($_ | Get-LocalGroupMembership).Name -join ', '}}
}

# Export results
$users | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "`n✅ User account audit complete!"
Write-Host "📂 Report saved to: $outputFile"
