function Analyze( $p, $f) {
    Get-ItemProperty $p | foreach {
        if (($_.DisplayName) -or ($_.version)) {
            [PSCustomObject]@{
                From            = $f;
                Name            = $_.DisplayName;
                Version         = $_.DisplayVersion;
                Install         = $_.InstallDate;
                Vendor          = $_.Vendor;
                SystemComponent = $_.SystemComponent;
            }
        }   
    }
}

$s = @()
$s += Analyze 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' 64
$s += Analyze 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*' 32
$s | Sort-Object -Property Name | Export-csv C:\installedapps.csv | Format-Table -Property Version, InstallDate, Name

### Other Commands to run in the shell:
# Get-Package |select Name, Version, Status, ProviderName, Source, FromTrustedSource, FastPackageReference| Export-Csv -Encoding utf8 -delimiter ";" -Path /path/to/outputfile.csv
# Get-AppxPackage | Export-Csv -Encoding Unicode -delimiter ";" "/path/to/outputfile.csv"
# Get-Package | select ProviderName, Source, Status, FullPath, PackageFilename, FromTrustedSource, Summary, Name, Version, Attributes | Export-Csv -Encoding Unicode -delimiter ";" "/path/to/outputfile.csv"


### Commands to run in CMD:
# wmic /output:c:\IstalledApps.htm product get Name, InstallDate, Version, Vendor /format:htable