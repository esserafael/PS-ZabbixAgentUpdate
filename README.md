# PS-ZabbixAgentUpdate
Powershell scripts that automatically update/install Zabbix agents on Windows Server infrastructure.

## Which does what
  - UpdateZabbixAgent.ps1 - This script is intended to be run on every single Windows server in your infrastructure. I suggest running it as a scheduled task, so you could easily deploy this task to all server with GPP (Group Policy Preferencies), or if you want to run the task with a custom user, you would have to import the task on every server, which is not very scalable.

  - DownloadUpdatedFiles.ps1 - This script is intended to be run regularly on a specific server (it could be a file server, or anything that can reach the Zabbix URL, etc.), to download the latest agent binaries from your Zabbix server to a central repository in your network, for easy management. It is essential that all your Windows servers can reach and read this location in the network, or the updates/install will fail. If you have an Active Directory domain installed, you could configure the script to store those binaries in the NETLOGON folder for example, for easy access.

  - The example_zabbix.conf is used as a template, so the script can change hostname, etc.

  - The .conf files are used to configure some script parameters, like file locations and URL's.

## How to use it

  1. Store the scripts and conf files (at least UpdateZabbixAgent.ps1) in some network folder, where all servers can reach.
  2. Create a central repository where the binaries will be stored, separated by architecture. Example: 
  ```\\mydomain.com\zabbix\win32``` and ```\\mydomain.com\zabbix\win64```
  3. Edit the example_zabbix.conf with your zabbix server address and preferences, and copy it to both folders (You can rename it whatever you want, just check the name is properly configured in the .conf files.
  4. Edit the UpdateZabbixAgent.conf and DownloadUpdatedFiles.conf to meet your enviroment scenario, like Zabbix binaries URL, network path, local path, file names, etc.
  5. Configure a server (or more if you are a availability freak) to run the DownloadUpdatedFiles.ps1 script periodically, it can be a scheduled task. That server will get the role of download the files to the central repository.
  6. Configure all Windows servers with zabbix agent installed (including the server from step 5), to run the UpdateZabbixAgent.ps1 script nightly or whatever schedule you need.
  7. You are done.
