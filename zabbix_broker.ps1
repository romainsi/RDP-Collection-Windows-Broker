# Script: zabbix_broker
# Author: Romainsi
# Description: Query RDP Windows Broker informations
# 
# This script is intended for use with Zabbix > 3.X
#
# USAGE:
#   as a script:    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent\scripts\zabbix_broker.ps1" <ITEM_TO_QUERY> <JOBID>"
#   as an item:     rdp[<ITEM_TO_QUERY>,<JOBID>]
#
# Add to Zabbix Agent
#   UserParameter=rdp[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent\scripts\zabbix_broker.ps1" "$1" "$2"
#
$pathxml = 'C:\Program Files\Zabbix Agent\scripts'
$pathsender = 'C:\Program Files\Zabbix Agent'

$ITEM = [string]$args[0]
$ID = [string]$args[1]
$ID0 = [string]$args[2]


switch ($ITEM) {
  "Discovery" {
    $output =  "{`"data`":["
    $query = Get-RDSessionCollection | select CollectionName | ForEach-Object -Process {Get-RDSessionHost -CollectionName $_.collectionname}
      $count = $query | Measure-Object
      $count = $count.count
      foreach ($object in $query) {
        $collectionName = [string]$object.CollectionName
        $sessionHost = [string]$object.SessionHost
        if ($count -eq 1) {
          $output = $output + "{`"{#COLLECTIONNAME}`":`"$collectionName`",`"{#RDPSERVER}`":`"$sessionHost`"}"
        } else {
          $output = $output + "{`"{#COLLECTIONNAME}`":`"$collectionName`",`"{#RDPSERVER}`":`"$sessionHost`"},"
        }
        $count--
    }
   $output = $output + "]}"

  $querysend = $output.Replace('"','\"') 
  cd $pathsender
  $trapper = .\zabbix_sender.exe -c .\zabbix_agentd.conf -k broker.Discovery -o $querysend -v
    if ($trapper[0].Contains("processed: 1"))
    {write-host "Execution reussie"}
    else {write-host "Execution non reussie"}
  }

    "Result"  {
  $query = Get-RDSessionHost -CollectionName $ID | Where-Object {$_.SessionHost -like "$ID0"} | Select NewConnectionAllowed
  $querysend1 = $query.NewConnectionAllowed
  $querysend = "$querysend1".replace('Yes','1').Replace('No','0')
  cd $pathsender
  $trapper = .\zabbix_sender.exe -c .\zabbix_agentd.conf -k connection.allow.[$ID0] -o $querysend -v
    if ($trapper[0].Contains("processed: 1"))
    {write-host "Execution reussie"}
  else {write-host "Execution non reussie"}
  }
  default {
      Write-Host "-- ERREUR -- : Besoin d'une option !"
  }
}
