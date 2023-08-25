# Define the registry key updates as a hashtable
$registryUpdates = @(
    @{
        Path  = 'HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\System'
        Value = 'HiberbootEnabled'
        Type  = 'DWORD'
        Data  = '1'
    },
    @{
        Path  = 'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\Power'
        Value = 'HiberbootEnabled'
        Type  = 'DWORD'
        Data  = '1'
    },
    @{
        Path  = 'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Power'
        Value = 'HibernateEnabled'
        Type  = 'DWORD'
        Data  = '1'
    },
    @{
        Path  = 'HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Power'
        Value = 'HibernateEnabledDefault'
        Type  = 'DWORD'
        Data  = '1'
    },
    @{
        Path  = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings'
        Value = 'ShowHibernateOption'
        Type  = 'DWORD'
        Data  = '1'
    },
    @{
        Path  = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System'
        Value = 'ShowHibernateOption'
        Type  = 'DWORD'
        Data  = '1'
    },
    @{
        Path  = 'HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization'
        Value = 'RestrictImplicitInkCollection'
        Type  = 'DWORD'
        Data  = '1'
    },
    @{
        Path  = 'HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization'
        Value = 'RestrictImplicitTextCollection'
        Type  = 'DWORD'
        Data  = '1'
    },
    @{
        Path  = 'HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore'
        Value = 'HarvestContacts'
        Type  = 'DWORD'
        Data  = '1'
    },
    @{
        Path  = 'HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings'
        Value = 'AcceptedPrivacyPolicy'
        Type  = 'DWORD'
        Data  = '1'
    }
)

# Iterate through the registry updates and apply changes
foreach ($update in $registryUpdates) {
    $path = $update.Path
    $value = $update.Value
    $type = $update.Type
    $data = $update.Data

    # Construct the full registry key path
    $fullPath = "Registry::$path"

    # Check if the registry key exists before updating
    if (Test-Path -Path $fullPath) {
        # Convert the data to the appropriate type
        $typedData = if ($type -eq 'REG_DWORD') { [System.Convert]::ToInt32($data) } else { $data }

        # Set the registry value
        Set-ItemProperty -Path $fullPath -Name $value -Value $typedData -Type $type

        # Print the update information
        Write-Host "Updated registry key: $fullPath\$value"
    }
    else {
        Write-Host "Registry key does not exist: $fullPath"
    }
}

Write-Host "Registry updates complete."
