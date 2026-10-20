set /p "GAME=Enter game (ex. SoulSilver English IPGE): "
for /f "delims=" %%F in ('dir /b /a-d "*.myg"') do (
    (echo %%F					936)>> "_list.txt"
)
docker exec pkmn-server cp /dummy-certs/_list.txt /var/www/dwc_network_server_emulator/dlc/%GAME%/_list.txt
docker exec pkmn-server sh -c "cp -f /dummy-certs/*.myg /var/www/dwc_network_server_emulator/dlc/%GAME%/"
