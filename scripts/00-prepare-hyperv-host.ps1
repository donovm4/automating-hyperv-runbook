# I guess we should check if the Hyper-V host is configured correctly

Get-Service WinRM

winrm enumerate winrm/config/listener