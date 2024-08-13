#This script will go to each server present in ServerDetails.txt
#Then search for the Schedule Tasks running under the user id
#Change the userid (if new user id is different from old one) and Password (New Password)

#Folder path where your server files present and log to be written
$FolderPath="FolderPath"
$logfilepath = $FolderPath + "\TasksLog.txt" #To write the output
#Server host name one below one in ServerDetails.txt  file
$ServerDetails= $FolderPath + "\ServerDetails.txt" 
#User id under shich Task is running for and for which you need to change the password
$UserID="UserId" 
#Old password that needs to be changed
$Password="OldPassword"
#Keep the old user id if you want to change only the password else use new user id
$NewUserID="UserID" 
$NewPwd="NewPassword"
$ChangePasswordOfTask="YES"

$TaskDirectory="\c$\Windows\System32\Tasks"
$VerbosePreference = "continue"
$Status=" "
Add-content -path $logfilepath -Value "computername,ServiceOrTask,UserID,Status"
Foreach ($ComputerName in (Get-Content $ServerDetails)) 
{

    $date=Get-Date
    Write-Verbose -Message "Getting Task details from $ComputerName - running under $UserID - $date"
    $path = "\\" + $computername + $TaskDirectory
    $tasks = Get-ChildItem -Path $path -File
    $date=Get-Date
    foreach ($tsk in $tasks)
    {
        $AbsolutePath = $path + "\" + $tsk.Name
        $task = [xml] (Get-Content $AbsolutePath)
        [STRING]$check = $task.Task.Principals.Principal.UserId

        if ($UserID -eq $check)
        {
            Write-Verbose -Message "         $computername,$tsk,$check"          
            if ($ChangePasswordOfTask -eq "YES")
            {
                Add-content -path $logfilepath -Value "$computername,$tsk,$UserID,Password Change Started"
                Write-Verbose -Message "         Changing the password of the job $tsk and user id $check"
                $Status=schtasks /change /s $computername /tn $tsk /ru $NewUserID /rp $NewPwd
            }
            Write-Verbose -Message $Status
            Add-content -path $logfilepath -Value ",$tsk,$UserID,$Status"
        }

    }
    
}