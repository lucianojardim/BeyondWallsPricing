Clear-Host;

###$filesystemroot = "c:\temp\BeyondWalls"
$filesystemroot = "E:\HNIGTMAS\WindowsPowerShell\BeyondWalls"

$pathExecutionLogs = "$filesystemroot\Logs\HNI-Export-eCatalogData"
Start-Transcript -Path "$pathExecutionLogs.$(Get-Date -Format "yyyyMMddHHmmss").log" 

Import-Module sqlps -DisableNameChecking

. "E:\HNIGTMAS\WindowsPowerShell\BeyondWalls\Export-XLSX.ps1"

set-PSDebug -Off; # Turns off all script debugging features
#set-psdebug -trace 0; # Turn script tracing off
#set-psdebug -trace 1; # Trace script lines as they are executed
#set-psdebug -trace 2; # Trace script lines, variable assignments, function calls, and scripts.

#$ErrorActionPreference ="Continue";
#$WarningPreference="Continue";
#$DebugPreference="SilentlyContinue";
$DebugPreference="Continue";

<#
  Parameters
#>
# Beyond Wall Pricing database
[string]$sqlServerInstance = "MUSHNI-EBZDBZ2Q";
[string]$sqlServerDatabase = "BeyondWallsPricing";
[string]$sqlUsername = "BeyondWallsUsr";
[string]$sqlUserPassword = "BeyondWallsUsr";
#eCatalog output file
[string]$pathToeCatalogOutputFile = "$filesystemroot\eCatalogReadyToBeProcessed"

[string]$pathToeCatalogPurgeFolder = "$filesystemroot\eCatalogReadyToBePurged"
$numDaysDeleteFiles = 31;
[int]$connectionTimeout = 60;
# List parameters
$programName = "HNI-Export-eCatalogData.ps1";
$Parameters = "$(Get-Date -Format s) $programName : Input parameters: `n";
$Parameters = $Parameters + "`$sqlServerInstance = $sqlServerInstance `n";
$Parameters = $Parameters + "`$sqlServerDatabase = $sqlServerDatabase `n";
$Parameters = $Parameters + "`$pathToeCatalogPurgeFolder = $pathToeCatalogPurgeFolder `n";
$Parameters = $Parameters + "`$numDaysDeleteFiles = $numDaysDeleteFiles `n";
Write-Debug $Parameters;

<#
  Email setup
#>
[String[]]$EmailAddressesApplicationSupport = @("jardiml@hnicorp.com");
[String[]]$EmailEcatalog = @("Ecatalog@hni01.hnicorp.com");
$SmptServer = "smtp-relay.honi.com";
$SmptPort = 25;
$From = "BeyondWalls@hnicorp.com";
$Subject = "Beyond Walls Pricing system: Failure while creating list price to be sent to eCatalog";
$Body = $Subject + "`n`n" + $Parameters;
try{
    Write-Debug "$(Get-Date -Format s) $programName : Testing connection to SQL Server `n";
    SQLPS\Invoke-Sqlcmd -Database $sqlServerDatabase -ServerInstance $sqlServerInstance -Query "SELECT [name] FROM [master].[sys].[databases]" -Username $sqlUsername -Password $sqlUserPassword -ConnectionTimeout $connectionTimeout | Out-Null
}catch{
    #Send email notifying
    $Body = $Body + "`n`n" + "Unable to connect to the SQL Server database.";
    $Body = $Body + "`n`n" + $Error[0];
    $Body = $Body + "`n`n" + "The program will abort.";
    Write-Debug $Body
    Send-MailMessage -To $EmailAddressesApplicationSupport -Subject $Subject -From $From -Body $Body -SmtpServer $SmptServer -Port $SmptPort;
    exit
}

$sql = "SELECT [ModelOptionsStringDesc] AS [PartNumber], CAST([ModelOptionsStringPrice] AS NUMERIC(16,2)) AS [Sell] FROM [dbo].[ModelOptionsString] WHERE [IsInEcatalog] = 0 AND [ModelOptionsStringPrice] IS NOT NULL ORDER BY [ModelOptionsStringDesc]"
try{
    $rows = @(SQLPS\Invoke-Sqlcmd -Database $sqlServerDatabase -ServerInstance $sqlServerInstance -Query $sql -Username $sqlUsername -Password $sqlUserPassword) 
    if($rows) {
        Write-Debug "List of rows from the database that have to be sent to the eCatalog team"
        Write-Debug ($rows | Out-String)

        $lines = @();
        foreach($row in $rows){
            [string[]]$arrayPartNumber = $row.PartNumber.Split(".");
            $sell = $row.Sell;
            $firstLine = $true;
            foreach($element in $arrayPartNumber){
                if($firstLine){
                    $sell = "{0:C2}" -f $sell;
                    $firstLine = $false
                }else{
                    $sell = "";
                    $element = "."+$element;
                }
                $line = New-Object -TypeName PSObject 
                # 2016-12-19 Removed this column from the excel per Donette G. request (via Brandon Garrette)
                #Add-Member -InputObject $line -MemberType NoteProperty -Name Item -Value "" -TypeName string 
                Add-Member -InputObject $line -MemberType NoteProperty -Name PartNumber -Value $element -TypeName string
                Add-Member -InputObject $line -MemberType NoteProperty -Name Sell -Value $sell -TypeName string
                $lines += $line;
            }
        }

        # Create excel file and send email to Ecatalog@hni01.hnicorp.com to have the file processed by the eCatalog team
        if($lines -ne @()){
            Write-Debug "List of objects that will be added to an excel file and sent to the eCatalog team"
            Write-Debug ($lines | Out-String)

            Write-Debug "Creates the excel file processing 500 lines at a time (limitation of the program that creates Excel files)"
            [int]$maxLinesSentExcel = 500*3 # rows * number of lines per row
            [int]$numLaps = ($lines.count/$maxLinesSentExcel) + 1
            [int]$indexSkip = 0
            for([int]$i = 1; $i -le $numLaps; $i++) {
                [string]$eCatalogOutputFileName = "$pathToeCatalogOutputFile\$(Get-Date -Format "yyyyMMddThhmmssmsms")Beyond.xlsx";
                Write-Debug "$eCatalogOutputFileName is going to be created to be sent to the eCatalog team";
                $lines | Select-Object -Skip $indexSkip -First $maxLinesSentExcel | Export-XLSX -Path $eCatalogOutputFileName
                Write-Debug "Send email to $EmailEcatalog if price for new model.options were added to the database"
                $Subject = $eCatalogOutputFileName
                $Body = $eCatalogOutputFileName
                Send-MailMessage -To $EmailEcatalog -Subject $Subject -From $From -Body $Body -SmtpServer $SmptServer -Port $SmptPort -Attachments $eCatalogOutputFileName
                $indexSkip = $indexSkip + $maxLinesSentExcel

                Write-Debug "Move $eCatalogOutputFileName to folder $pathToeCatalogPurgeFolder where files are purged later"
                Move-Item -Path $eCatalogOutputFileName -Destination $pathToeCatalogPurgeFolder -Force -ErrorAction Continue -WarningAction Continue
            }
        
            Write-Debug "Prepare SQL Update statements to mark that the row was sent to the eCatalog team"
            [string]$sql = "BEGIN TRANSACTION;`n";
            $rows | ForEach-Object {$sql = $sql + "UPDATE [dbo].[ModelOptionsString] SET [IsInEcatalog] = 1 WHERE [ModelOptionsStringDesc] = '"+$_.PartNumber.ToString().Trim()+"'; IF @@ERROR <> 0 BEGIN ROLLBACK; RAISERROR ('Error raised',16,1); RETURN; END;`n"}
            $sql = $sql + "COMMIT;`n"
            Write-Debug "Execute command to Update IsInEcatalog"
            $sql
            SQLPS\Invoke-Sqlcmd -Database $sqlServerDatabase -ServerInstance $sqlServerInstance -Query $sql -Username $sqlUsername -Password $sqlUserPassword -ConnectionTimeout $connectionTimeout
        
        }else{
            Write-Debug "Excel file was not created because the app didn't find any new prices that need to be processed by the eCatalog team."
        }
    }else{
        Write-Debug "Nothing to be processed. The database returned an empty result set."
    }
}catch{
    #Send email notifying
    $Subject = "Beyond Walls Pricing system: Failure while creating list price to be sent to eCatalog";
    $Body = $Subject + "`n`n" + $Parameters;
    $Body = $Body + "`n`n" + "File with price information could not be sent to eCatalog.";
    $Body = $Body + "`n`n" + $Error[0];
    $Body = $Body + "`n`n" + "The program will abort.";
    $Body
    Send-MailMessage -To $EmailAddressesApplicationSupport -Subject $Subject -From $From -Body $Body -SmtpServer $SmptServer -Port $SmptPort;
    exit
}


# Delete unnecessary files based on when they were created
if($numDaysDeleteFiles -lt 0){
    $numDaysDeleteFiles = 31
}
[string]$displayNumDays = $numDaysDeleteFiles
$numDaysDeleteFiles = $numDaysDeleteFiles *-1
Write-Debug "Delete files that are older than $displayNumDays days" # (Brandon Garrett determined the retention period)
get-childitem $pathToeCatalogPurgeFolder | Where-Object {$_.lastwritetime -lt (get-date).adddays($numDaysDeleteFiles) -and -not $_.psiscontainer} | ForEach-Object {remove-item $_.fullname -force -verbose}
get-childitem "$pathExecutionLogs*" | Where-Object {$_.lastwritetime -lt (get-date).adddays($numDaysDeleteFiles) -and -not $_.psiscontainer} | ForEach-Object {remove-item $_.fullname -force -verbose}

Stop-Transcript