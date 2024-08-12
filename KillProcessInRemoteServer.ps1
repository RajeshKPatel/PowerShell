[cmdletbinding()]
$FolderPath="Directory" #Path of the directory which contains all the Server details from which process should be killed
$ProcessName="Process.exe" #Process name to kill in remote servers
$date=Get-Date
$Logfile= "$FolderPath\Log$date.txt" #Logging
write-host "Server check Started - $date"
Foreach ($ComputerName in (Get-Content $FolderPath\ServerDetails.txt)) #ServerDetails.txt should contain Hostname one per line in the file
{ 
    $date=Get-Date
    write-host "Checking for the server $ComputerName - $date"
    $Processes = Get-WmiObject -Class Win32_Process -ComputerName $ComputerName -Filter "name='$ProcessName'"
    $processid = $Processes.handle
    $Memory=$Processes.WorkingSetSize
    #Checking if the process utilizing memory more than 1 GB then kill
    #you can remove if you just want to kill a processs without any condition
    if ($Processes.WorkingSetSize -gt "10000000") 
    {
        Add-content $Logfile -value "The process $ProcessName ($processid) having memory $Memory is turminated on server $ComputerName $date"
        $Processes.Terminate()        
    }
}
$date=Get-Date
write-host "Server check Ended - $date"