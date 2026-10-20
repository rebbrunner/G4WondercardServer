set /p UserIP="Please enter your IP address: "
echo address=/nintendowifi.net/%UserIP% > "dnsmasq\wfc.conf"
docker exec pkmn-server ./gen_cert.sh
docker stop pkmn-server && docker start pkmn-server

@echo off
echo Please visit `localhost/?page=admin^&section=Dashboard` in a web browser of your choosing and white list your game.
echo ^| username: admin ^| password: opensesame ^|
echo ^| title ^| code ^|
echo ^| --- ^| --- ^|
echo ^| Diamond ^| ADA ^|
echo ^| Pearl ^| APA ^|
echo ^| Platinum ^| CPU ^|
echo ^| HeartGold ^| IPK ^|
echo ^| SoulSilver ^| IPG ^|
pause
