#This script will go to each server present in ServerDetails.txt
#Then search for the Windows running under the user id
#Change the userid (if new user id is different from old one) and Password (New Password)

#It will Stop the Windows service->Change The Password->Start the service in All the server one by one

#Folder path where your server files present and log to be written
$FolderPath="FolderPath"
$logfilepath = $FolderPath + "\Log.txt" #To write the output
#Server host name one below one in ServerDetails.txt  file
$ServerDetails= $FolderPath + "\ServerDetails.txt" 
#User id under shich Task is running for and for which you need to change the password
$UserID="UserId" 

#Keep the old user id if you want to change only the password else use new user id
$NewUserID="UserID" 
$NewPwd="NewPassword"
$ChangePasswordOfService="YES" #change to No if yiu just want to debug the code without changing password
$VerbosePreference = "continue"

Add-content -path $logfilepath -Value "computername,WindowsService,UserID,Stauts"

Foreach ($ComputerName in (Get-Content $ServerDetails)) 
{
    $date=Get-Date
    Write-Verbose -Message "Getting Service details from $ComputerName - running under $UserID - $date"
    $ServiceDetails=@(Get-WmiObject -Class Win32_Service -ComputerName $ComputerName | ? startname -like $UserID| Select-Object Name,StartName,StartModel,State)
    foreach ( $Service in $ServiceDetails)
    {
        $serviceName=$Service.Name
        $serviceStatus=$Service.State
        Add-content -path $logfilepath -Value "$ComputerName,$serviceName,$UserID,$serviceStatus"
        Write-Verbose -Message "                          $serviceName,$UserID,$serviceStatus"
        if ($ChangePasswordOfService -eq "YES")
        {  
            $svcD=gwmi win32_service -computername $ComputerName -filter "name='$serviceName'"
            Add-content -path $logfilepath -Value ",$serviceName,$UserID,Stopping Service"
            $StopStatus = $svcD.StopService() 
            If ($StopStatus.ReturnValue -eq "0") 
                {
                    write-host "$serviceName -> Service Stopped Successfully"
                    Add-content -path $logfilepath -Value ",$serviceName,$UserID,Service Stopped Successfully"
                }
            else
                {
                    Add-content -path $logfilepath -Value ",$serviceName,$UserID,ERROR"
                } 
            $ChangeStatus = $svcD.change($null,$null,$null,$null,$null,$null,$NewUserID,$NewPwd,$null,$null,$null) 
            If ($ChangeStatus.ReturnValue -eq "0")  
                {
                    write-host "$serviceName -> Sucessfully Changed User Name and Password"
                    Add-content -path $logfilepath -Value ",$serviceName,$UserID,Service Password Successfully"
                }
            else
                {
                    Add-content -path $logfilepath -Value ",$serviceName,$UserID,ERROR"
                } 
            $StartStatus = $svcD.StartService() 
            If ($StartStatus.ReturnValue -eq "0")  
                {
                    write-host "$serviceName -> Service Started Successfully"
                    Add-content -path $logfilepath -Value ",$serviceName,$UserID,Service Started Successfully"
                }
            else
                {
                    Add-content -path $logfilepath -Value ",$serviceName,$UserID,ERROR"
                } 
        }
    }
    
}