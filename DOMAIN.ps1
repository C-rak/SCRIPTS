
 #create FOREST& DOMAIN 
 #NOTE: complexitypassword means the single character password which you want to set.
 #prepare CSV with computername,domainname,password,complexitypassword,NetBIOSname

#NOTE: above stated parameters are used in script so it nessasry to provide same name as provided above.

#To set IPaddress provide your ip in below commend 
$index=Get-NetAdapter|select ifindex
New-NetIPAddress -InterfaceIndex $index.ifIndex -IPAddress 192.168.1.1 -PrefixLength 24

#import csv computerdetails
$computerdetails=Import-Csv C:\computerdetails.csv

#rename computer below command get name from csv 
Rename-Computer -NewName $computerdetails.computername -Restart 

#import csv computerdetails
$computerdetails=Import-Csv C:\computerdetails.csv

# below are passwrods credential which are needed in scrpit.
$domainpassword=$computerdetails.password|ConvertTo-SecureString -AsPlainText -Force

#To add ADDS 
Add-WindowsFeature -Name AD-Domain-Services -IncludeAllSubFeature -IncludeManagementTools

# To configure forest & DC

{Install-ADDSForest -DomainName $computerdetails.domainname -SafeModeAdministratorPassword $domainpassword `
       -DomainMode "WinThreshold" -ForestMode "WinThreshold" -DomainNetbiosName $computerdetails.NetBIOSname `
      -CreateDnsDelegation:$false -InstallDns:$true -DatabasePath "C:\Windows\NTDS" -LogPath "C:\Windows\NTDS"`
       -SysvolPath "C:\Windows\SYSVOL" -NoRebootOnCompletion:$false -Force:$true }

#TO remove complexity of password
$computerdetails=Import-Csv C:\computerdetails.csv

Set-ADDefaultDomainPasswordPolicy -ComplexityEnabled $false -MinPasswordLength 1 -Identity $computerdetails.domainname

#to Reset administrator password 
$singlepassword=$computerdetails.complexitypassword|ConvertTo-SecureString -AsPlainText -Force

Get-ADUser administrator |Set-ADAccountPassword -NewPassword $singlepassword

#LOG-OFF & Log-in

logoff




