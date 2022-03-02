# RDP-Collection-Windows-Broker

The script retrieve all informations in one shot and send it to zabbix server/proxy in json.

Discovery all servers in RDS collections.
Checks if the server(s) are draining (not allowed connections) and activate the trigger.

Retrieve informations about Collections :
- Use NLA for connection
- Automatic reconnection
- Redirection for the following entities 
- Use the client's default print device
- Allow printer redirection
- Encryption level	
- New connection allowed
- Relative weight
- Security layer
- Delete temporary folders on exit
- AD group RDS connection
- Status UPD

Check service state (disable it if you already use Template for discovery all windows services) : 
- RemoteApp Connections Administration and Remote Desktop Services
- Internal Windows database (WID)
- Service Broker for remote desktop connections<br><br>

**-- Setup --**

- Install the Zabbix Agent2 (ajust script if you use classique zabbix_agentd) on your host<br>
- Copy zabbix_broker.ps1 in the directory : "C:\Program Files\Zabbix Agent2\scripts" (create folder if not exist or ajust script)<br>
- Add the following line to your Zabbix agent configuration file.<br>
- `AllowKey=system.run[*]` if you use agent2 or EnableRemoteCommands=1 with zabbixAgentd (or create userparameter and change zabbix item "Start Broker Job")<br>
- UnsafeUserParameters=1 (probably not necessary) <br>
- ServerActive="IP or DNS Zabbix Server"<br>
- Import Template_App_Windows_Broker.yaml file into Zabbix.<br>
- Associate "Template App Windows Broker" to the host.<br><br>

Template is in FRENCH.<br>
Template for zabbix 5.4.10 (please modify template for work on older versions)
