<#
.Synopsis
    Script to remove any applicaion by searching the registry and matching specified criteria
.Description
    The Script will use the Parameters passed to it to search the registry.
    If matches are found the uninstall string will be run to remove the found product.
.Example
    Remove application with Display name and version number:

    Remove-Application -DisplayName "BCA" -Version "91" -Verbose
.Example
    Remove applicaiton with Publisher only:

    Remove-Application -Publisher "eClinical*" -Verbose
.Example
    Remove applcation with DisplayName only:

    Remove-Application -DisplayName "Adobe Shockwave*" -Verbose
.Notes
    Before running this script add one of the above examples to the end of the script and save as a new file name.
.Notes
    Author: Ortizn
    Date:   03/24/2020
#>



    

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$false, HelpMessage="Enter wildcard DisplayName of the product to remove.")]
    [string]$DisplayName,

    [Parameter(Mandatory=$false, HelpMessage="Enter Display Major Version only. Exp `"12`"")]
    [string]$Version,

    [Parameter(Mandatory=$false, HelpMessage="Enter wildcard Publisher of the prodcuts to remove.")]
    [string]$Publisher,

    [Parameter(Mandatory=$false)]
    $RegHives = @("HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall")        
)

Process {
    
    #Parameter check and operation selection
    if (($DisplayName -eq $null) -and ($Version -eq $null) -and ($Publisher -ne $null)) {
        $RegHives | ForEach-Object {
            $keys = Get-ChildItem $_ -Recurse
            $keys | ForEach-Object {
                $displaynamereg = [string]$_.GetValue("DisplayName")
                $PublisherName = [string]$_.GetValue("Publisher")
                $uninstallReg = [string]$_.GetValue("UninstallString")
                $MSIcode = ([string]$_.GetValue("UninstallString")).ToLower().Replace("/x","").Replace("msiexec.exe","").Replace("/i","")
                if (($PublisherName -like $Publisher) -and ($uninstallReg -like "msiexec*")) {
                    Write-Output "Found $displaynamereg starting uninstall.."
                    Start-Process "msiexec.exe" -ArgumentList "/x $MSIcode /qn /norestart" -Wait
                }
            }
        }
    }
    elseif (($Publisher -eq $null) -and ($Version -eq $null) -and ($DisplayName -ne $null)) {
        $RegHives | ForEach-Object {
            $keys = Get-ChildItem $_ -Recurse
            $keys | ForEach-Object {
                $displaynamereg = [string]$_.GetValue("DisplayName")
                $uninstallReg = [string]$_.GetValue("UninstallString")
                $MSIcode = ([string]$_.GetValue("UninstallString")).ToLower().Replace("/x","").Replace("msiexec.exe","").Replace("/i","")
                if (($displaynamereg -like $DisplayName) -and ($uninstallReg -like "msiexec*")) {
                    Write-Output "Found $displaynamereg starting uninstall.."
                    Start-Process "msiexec.exe" -ArgumentList "/x $MSIcode /qn /norestart" -Wait
                }
            }
        }
    }
    elseif (($DisplayName -ne $null) -and ($Version -ne $null) -and ($Publisher -eq $null)) {
        $RegHives | ForEach-Object {
            $keys = Get-ChildItem $_ -Recurse
            $keys | ForEach-Object {
                $displaynamereg = [string]$_.GetValue("DisplayName")
                $displayVersion = [string]$_.GetValue("DisplayVersion")                
                $MSIcode = ([string]$_.GetValue("UninstallString")).ToLower().Replace("/x","").Replace("msiexec.exe","").Replace("/i","")
                if (($displaynamereg -like $DisplayName) -and ($displayVersion.StartsWith($version))) {
                    Write-Output "Found $displaynamereg starting uninstall.."
                    Start-Process "msiexec.exe" -ArgumentList "/x $MSIcode /qn /norestart" -Wait
                }
            }
        }
    }
    elseif (($DisplayName -eq $null) -and ($Publisher -eq $null) -and ($Version -eq $null)) {
        Write-Output "No valid parameters specified"; break
    }
}
End {
    if (($DisplayName -eq $null) -and ($Version -eq $null) -and ($Publisher -ne $null)) {
        $RegHives | ForEach-Object {
            $keys = Get-ChildItem $_ -Recurse
            $keys | ForEach-Object {
                $displaynamereg = [string]$_.GetValue("DisplayName")
                $PublisherName = [string]$_.GetValue("Publisher")
                $uninstallReg = [string]$_.GetValue("UninstallString")                
                if (($PublisherName -like $Publisher) -and ($uninstallReg -like "msiexec*")){
                    Write-Output "$displaynamereg Failed Uninstall"; break
                }
            }
        }
    }
    elseif (($Publisher -eq $null) -and ($Version -eq $null) -and ($DisplayName -ne $null)) {
        $RegHives | ForEach-Object {
            $keys = Get-ChildItem $_ -Recurse
            $keys | ForEach-Object {
                $displaynamereg = [string]$_.GetValue("DisplayName")
                $uninstallReg = [string]$_.GetValue("UninstallString")                
                if (($displaynamereg -like $DisplayName) -and ($uninstallReg -like "msiexec*")){
                    Write-Output "$displaynamereg Failed Uninstall"; break
                }
            }
        }
    }
    elseif (($DisplayName -ne $null) -and ($Version -ne $null) -and ($Publisher -eq $null)) {
        $RegHives | ForEach-Object {
            $keys = Get-ChildItem $_ -Recurse
            $keys | ForEach-Object {
                $displaynamereg = [string]$_.GetValue("DisplayName")
                $displayVersion = [string]$_.GetValue("DisplayVersion")                
                if (($displaynamereg -like $DisplayName) -and ($displayVersion.StartsWith($version))){
                    Write-Output "$displaynamereg Failed to Uninstall"; break
                }
            }
        }
    }
    else {
        Write-Output "All products successfull removed"; break
    }
}

