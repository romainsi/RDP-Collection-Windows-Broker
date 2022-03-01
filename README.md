# RDP-Collection-Windows-Broker

Discovery all servers in RDS collection.
Checks if the server(s) are draining (not allowed connections) and activate the trigger.

Check service state : 
- RemoteApp Connections Administration and Remote Desktop Services
- Internal Windows database (WID)
- Service Broker for remote desktop connections<br><br>

**-- Setup --**

- Install the Zabbix agent on your host<br>
- Copy zabbix_broker.ps1 in the directory : "C:\Program Files\Zabbix Agent\scripts" (create folder if not exist)<br>
- Add the following line to your Zabbix agent configuration file.<br>
- EnableRemoteCommands=1 <br>
- UnsafeUserParameters=1 <br>
- ServerActive="IP or DNS Zabbix Server"<br>
- UserParameter=broker[*],powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Program Files\Zabbix Agent\scripts\zabbix_broker.ps1" "$1" "$2"<br>
- Import TemplateRdsCollections.xml file into Zabbix.<br>
- Associate "Template RDS Collections" to the host.<br><br>

Template is in french.<br>
Template for zabbix 3.4.X (please modify template for work on older versions)
