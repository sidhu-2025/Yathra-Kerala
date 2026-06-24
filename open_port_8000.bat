@echo off
echo Opening port 8000 for Django backend...
netsh advfirewall firewall add rule name="Django Backend 8000" dir=in action=allow protocol=TCP localport=8000 profile=any
echo Done! Port 8000 is now open.
pause
