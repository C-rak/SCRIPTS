## RUN THIS COMMAND IN EVERY MACHINE FORM enable-psremoting to set-item
#To enbale psremoting it is necessary to add trusted host 
#IN Line no.15 provide your client ipaddress example "192.168.1.1,192.168.1.2" for multiple clients or to apply any ip address just put "*"
 

Enable-psremoting

Set-NetConnectionProfile -NetworkCategory Private

New-NetFirewallRule -DisplayName "Windows Remote Management (HTTPS-In)" -Name "Windows Remote Management (HTTPS-In)" -Profile Any -LocalPort 5986 -Protocol TCP

$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "DESKTOP-MKOHOM6"

Export-Certificate  -Cert $Cert -FilePath "C:\Temp"

New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint –Force

Set-Item wsman:\localhost\Client\TrustedHosts -Value "192.168.1.1" -Concatenate -Force

$SkipCA=New-PSSessionOption -SkipCACheck -SkipCNCheck


#import csv create csv file with computer name 
$computers=Import-Csv C:\comp.csv 
$renamecomp=Import-Csv c:\renamecomp.csv

foreach($comp in $computers)

{
    $username = $comp.username
    $password = $comp.password | ConvertTo-SecureString -AsPlainText -Force

    $credential = New-Object -TypeName System.Management.Automation.PSCredential $username,$password

    
    
        test-connection -ComputerName $comp.computername -ErrorVariable EV -ErrorAction SilentlyContinue -Count 1
        If($EV -ne $null)
        {
            "not able to reach to $($comp.computername)" | out-file C:\error.log -Append
        
        }
        else
        {Invoke-Command -ComputerName $comp.computername -Credential $credential -Port 5986 -UseSSL -SessionOption $SkipCA -ScriptBlock {

          Rename-Computer -NewName $renamecomp.computername -Restart -Force 

         Set-DnsClientServerAddress -InterfaceIndex 3 -ServerAddresses 192.168.1.1 

         New-Item -Path C:\WELCOME.TXT -ItemType "file" -Value "WELCOME TO NTMS>LOCAL"
        
            $Dusername="ntms\administrator"
            $Dname="ntms.local"
           $Dpassword="a"|ConvertTo-SecureString -AsPlainText -Force
                $cred=New-Object -TypeName "System.Management.Automation.PSCredential" -ArgumentList $Dusername,$Dpassword
         
        Add-Computer -ComputerName $env:COMPUTERNAME -DomainName $Dname -Credential $cred -Restart -Force -Verbose
         
          }
        
        
        
        }
        
        
         
} 








