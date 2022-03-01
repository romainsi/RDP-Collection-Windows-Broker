# Script: zabbix_broker
# Author: Romainsi
# Description: Query RDP Windows Broker informations
#

$pathsender = 'C:\Program Files\Zabbix Agent 2'

$return = $null
$return = @()

$query = Get-RDSessionCollection 
$query1 = $query | select CollectionName | ForEach-Object -Process { Get-RDSessionHost -CollectionName $_.collectionname }

foreach ($item in $query1) {
    $Object = $null
    $Object = New-Object System.Object
    $Object | Add-Member -type NoteProperty -Name CollectionName -Value $item.CollectionName
    $Object | Add-Member -type NoteProperty -Name SessionHost -Value $item.SessionHost
    $NewConnectionAllowed = $item.NewConnectionAllowed
    $Object | Add-Member -type NoteProperty -Name NewConnectionAllowed -Value ($NewConnectionAllowed -replace('Yes', '1') -Replace('No', '0'))

    $UPD = Get-RDSessionCollectionConfiguration -CollectionName $item.CollectionName -UserProfileDisk
    $Object | Add-Member -type NoteProperty -Name UserProfileDisk -Value $UPD.EnableUserProfileDisk
                    
    #$UserGroup = Get-RDSessionCollectionConfiguration -CollectionName $item.CollectionName -UserGroup
    #$Object | Add-Member -type NoteProperty -Name UserGroup -Value ("'" + $UserGroup.UserGroup + "'")

    $Connection = Get-RDSessionCollectionConfiguration -CollectionName $item.CollectionName -Connection
    $Object | Add-Member -type NoteProperty -Name DisconnectedSessionLimitMin -Value $Connection.DisconnectedSessionLimitMin
    $Object | Add-Member -type NoteProperty -Name IdleSessionLimitMin -Value $Connection.IdleSessionLimitMin
    $Object | Add-Member -type NoteProperty -Name ActiveSessionLimitMin -Value $Connection.ActiveSessionLimitMin
    $Object | Add-Member -type NoteProperty -Name BrokenConnectionAction -Value $Connection.BrokenConnectionAction
    $Object | Add-Member -type NoteProperty -Name AutomaticReconnectionEnabled -Value $Connection.AutomaticReconnectionEnabled
    $Object | Add-Member -type NoteProperty -Name TemporaryFoldersDeletedOnExit -Value $Connection.TemporaryFoldersDeletedOnExit

    $Security = Get-RDSessionCollectionConfiguration -CollectionName $item.CollectionName -Security
    $Object | Add-Member -type NoteProperty -Name AuthenticateUsingNLA -Value $Security.AuthenticateUsingNLA
    $Object | Add-Member -type NoteProperty -Name EncryptionLevel -Value $Security.EncryptionLevel
    $Object | Add-Member -type NoteProperty -Name SecurityLayer -Value $Security.SecurityLayer
					
    $LoadBalancing = Get-RDSessionCollectionConfiguration -CollectionName $item.CollectionName -LoadBalancing | where { $_.SessionHost -like $item.SessionHost }
    if (!$LoadBalancing.RelativeWeight) { $Object | Add-Member -type NoteProperty -Name LoadBalancing -Value "Standalone Server" }
    else { $Object | Add-Member -type NoteProperty -Name LoadBalancing -Value $LoadBalancing.RelativeWeight }
					

    $Client = Get-RDSessionCollectionConfiguration -CollectionName $item.CollectionName -Client
    if ($Client.ClientPrinterRedirected -like '1') { $Object | Add-Member -type NoteProperty -Name ClientPrinterRedirected -Value "True" }
    else { $Object | Add-Member -type NoteProperty -Name ClientPrinterRedirected -Value "False" }

    if ($Client.ClientPrinterAsDefault -like '1') { $Object | Add-Member -type NoteProperty -Name ClientPrinterAsDefault -Value "True" }
    else { $Object | Add-Member -type NoteProperty -Name ClientPrinterAsDefault -Value "False" }

    if ($Client.ClientDeviceRedirectionOptions -like '1') { $Object | Add-Member -type NoteProperty -Name ClientDeviceRedirectionOptions -Value "True" }
    else { $Object | Add-Member -type NoteProperty -Name ClientDeviceRedirectionOptions -Value "False" }

    $Return += $Object
}

$Return = ConvertTo-Json -Compress -InputObject @($return)
$Return = $Return -replace '\"true\"', 'true' -replace '\"false\"', 'false'
$Return = $Return -replace '\"1\"', '1' -replace '\"0\"', '0'
$Return = $Return -replace '"', '\"'
$Return = '\"' + $return + '\"'

cd $pathsender
.\zabbix_sender.exe -c .\zabbix_agent2.conf -k ResultsBroker -o $Return
