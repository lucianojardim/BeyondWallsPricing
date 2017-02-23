Clear-Host;

###$filesystemroot = "c:\temp\BeyondWalls"
$filesystemroot = "E:\HNIGTMAS\WindowsPowerShell\BeyondWalls"

$pathExecutionLogs = "$filesystemroot\Logs"
$pathExecutionLogsAndPrefix = "$pathExecutionLogs\HNI-LoadCostFromBmiBatchIntoSqlServer"
Start-Transcript -Path "$pathExecutionLogsAndPrefix.$(Get-Date -Format "yyyyMMddHHmmss").log"

Import-Module sqlps -DisableNameChecking

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
[string]$sqlServerDatabase = "BeyondWallsPricingInternal";
[string]$sqlServerTableName = "[dbo].[CostFromBmiBatch]";
[string]$sqlUsername = "BeyondWallsUsr";
[string]$sqlUserPassword = "BeyondWallsUsr";
# BMIBATCH folders
[string]$bmiBatchFileType = "csv";
[string]$pathFromBmiBatch = "\\mushni-flpin01p\TDrive\MISMFG\BMIBATCH\WALLS_CET\qa";
[string]$pathReadyToBeProcessed = "$filesystemroot\BeyondWallsReadyToBeProcessed";
[string]$pathReadyToBePurged = "$filesystemroot\BeyondWallsReadyToBePurged";
[int]$numDaysDeleteFiles = 31;
[int]$connectionTimeout = 60;
# List parameters
$programName = "HNI-LoadCostFromBmiBatchIntoSqlServer.ps1";
$Parameters = "$(Get-Date -Format s) $programName : Input parameters: `n";
$Parameters = $Parameters + "`$sqlServerInstance = $sqlServerInstance `n";
$Parameters = $Parameters + "`$sqlServerDatabase = $sqlServerDatabase `n";
$Parameters = $Parameters + "`$sqlServerTableName = $sqlServerTableName `n";
$Parameters = $Parameters + "`$pathFromBmiBatch = $pathFromBmiBatch `n";
$Parameters = $Parameters + "`$pathReadyToBeProcessed = $pathReadyToBeProcessed `n";
$Parameters = $Parameters + "`$pathReadyToBePurged = $pathReadyToBePurged `n";
$Parameters = $Parameters + "`$numDaysDeleteFiles = $numDaysDeleteFiles `n";
Write-Debug $Parameters;

<#
  Email setup
#>
[String[]]$EmailAddressesApplicationSupport = @("jardiml@hnicorp.com");
$SmptServer = "smtp-relay.honi.com";
$SmptPort = 25;
$From = "BeyondWalls@hnicorp.com";
$Subject = "Beyond Wall Pricing system: Failure while processing cost information sent by BMIBATCH";
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

try{ 
    Write-Debug "List files from BmiBatch (if any)"
    Set-Location c:  #THIS IS A CRITICAL LINE -- without it Get-ChildItem will fail if you are using a remote UNC
    Get-ChildItem -Name $pathFromBmiBatch

    # Move to Ready to be Processed
    Move-Item -Path "$pathFromBmiBatch\*.$bmiBatchFileType" -Destination $pathReadyToBeProcessed -Force -ErrorAction Continue -WarningAction Continue 

    Write-Debug "List files ready to be processed (if any)"
    Get-ChildItem $pathReadyToBeProcessed

    $pathToInputFiles = "$pathReadyToBeProcessed\*.$bmiBatchFileType"
    [string]$sql = "BEGIN TRANSACTION;`nDECLARE @ModelOptions VARCHAR(60);`n";
    [string[]]$bmiBatchFileFullNames = @(Get-ChildItem -Path $pathToInputFiles | Select-Object -ExpandProperty FullName)
    foreach($fullFileName in $bmiBatchFileFullNames){
        Write-Debug "$(Get-Date -Format s) $programName : Processing $fullFileName"
        [datetime]$bmiBatchFileLastWriteTime = Get-ChildItem -Path $fullFileName | Select-Object -ExpandProperty  LastWriteTime;
        #Load the data into SQL Server
        Import-Csv -Path $fullFileName | ForEach-Object {
            if ($_."Unit Total") {
                $UnitTotal=$_."Unit Total"
            } else {
                $UnitTotal="NULL"
            }
            [string]$ModelOptions = $_."Model.Options".ToString().Trim()
	        # $ is a special character for SQLCMD and has to be removed from the string
            $sql = $sql + "SET @ModelOptions = '"+$ModelOptions.Replace("$","'+CHAR(36)+'")+"';`n"
            $sql = $sql + "INSERT INTO $sqlServerTableName ([CostFromBmiBatchId],[Model],[Model.Options],[Unit Total],[Errors?],[BmiBatchFullFileName],[BmiBatchFileLastWriteTime],[LoadDateTime]) VALUES ((NEWID()),'"+$_.Model.ToString().Trim()+"',@ModelOptions,"+$UnitTotal+",'"+$_."Errors?".ToString().Trim()+"','"+$fullFileName+"',CAST('"+$bmiBatchFileLastWriteTime+"' AS DATETIME), GETDATE()); IF @@ERROR <> 0 BEGIN ROLLBACK; RAISERROR ('Error raised',16,1); RETURN; END;`n"
        }
    }

    if ($sql.Contains("INSERT")) {
        $sql = $sql + "COMMIT;`n"
        Write-Debug "Insert data from BMIBATCH"
        $sql
        SQLPS\Invoke-Sqlcmd -Database $sqlServerDatabase -ServerInstance $sqlServerInstance -Query $sql -Username $sqlUsername -Password $sqlUserPassword -ConnectionTimeout $connectionTimeout
    } else {
        Write-Debug "No data from BMIBATCH has to be inserted in the database"
    }

    # Move to Ready to be Purged
    Move-Item -Path "$pathReadyToBeProcessed\*.$bmiBatchFileType" -Destination $pathReadyToBePurged -Force -ErrorAction Continue -WarningAction Continue
    
    Write-Debug "Finished processing all files (if any)"
}catch{
    #Send email notifying of error
    $Body = $Body + "`n`n" + "File from BMIBATCH could not be loaded into the database.";
    $Body = $Body + "`n`n" + $Error[0];
    $Body = $Body + "`n`n" + "The program will abort.";
    Send-MailMessage -To $EmailAddressesApplicationSupport -Subject $Subject -From $From -Body $Body -SmtpServer $SmptServer -Port $SmptPort;
    exit
}


if($numDaysDeleteFiles -lt 0){
    $numDaysDeleteFiles = 31
}
[string]$displayNumDays = $numDaysDeleteFiles
$numDaysDeleteFiles = $numDaysDeleteFiles *-1
Write-Debug "Delete files that are older than $displayNumDays days" # (Brandon Garrett determined the retention period)
(get-childitem $pathReadyToBePurged) + (get-childitem "$pathExecutionLogsAndPrefix*") | Where-Object {$_.lastwritetime -lt (get-date).adddays($numDaysDeleteFiles) -and -not $_.psiscontainer} | ForEach-Object {remove-item $_.fullname -force -verbose}

Stop-Transcript