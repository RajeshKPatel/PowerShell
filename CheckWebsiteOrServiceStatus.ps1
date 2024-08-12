[cmdletbinding()]
$FolderPath="D:\your_folder_path" #folder path for the file which contains the website/service list
$From="From@email.id"
$WebAddressFile=$FolderPath+"\WebsAddress.txt"
$To="To@email.id" #individual email id with ; seprated or group email id
$SMTPServer="smtpserver.xyz.com" #your SMTP server using which mail will be sent
$IsError=0
$Subject="Error: "

Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertficatePolicy {
        public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem)   
        {
            return true;
        }
    }
"@

[Systed.Net.ServicePointManager]::CerrtificatePolicy=New-Object TrustAllCertsPolicy

foreach ($Webaddress in (Get-Content $WebAddressFile)) { #This will read the webaddress file one by one
    $date=Get-Date
    Write-Host $Webaddress, $date, "-Start"
    try {
        $HTTP_Request = [System.Net.WebRequest]::Create($Webaddress)
        $HTTP_Response = $HTTP_Request.GetResponse()
        $HTTP_Status = [int]$HTTP_Response.StatusCode
        if ($HTTP_Status -eq 200) {
            Write-Host "Success"
        }
        else {
            $IsError=1
            $Subject=$Subject + ","+$Webaddress+" Is in error state"
            Write-Host "Error"
        }
    }
    catch {
        $IsError=1
        $Subject=$Subject + ","+$Webaddress+" Is in error state"
        Write-Host "Error"
    }

    $HTTP_Response.Close()

}

if ($IsError -eq 1) {
    $date=Get-Date
    $val=$date.ToString()+" : "+$Subject
    Add-Content -Value "$val" -Path $FolderPath"\Log.txt"
    $Body="Error in Webaddress"
    Send-MailMessage -SmtpServer $SMTPServer -To $To -From $From -BodyAsHtml $Body -Subject $Subject -Priority High

}
else {
    $date=Get-Date
    $val=$date.ToString()+" : No issue Found"
    Add-Content -Value "$val" -Path $FolderPath"\Log.txt"
}