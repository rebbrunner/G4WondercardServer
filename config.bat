set /p UserIP="Please enter your IP address: "
tar -xf ./rce-pak.zip
echo address=/nintendowifi.net/%UserIP% > "configs\wfc.conf"
docker exec pkmn-server ./gen_cert.sh
docker compose up -d
docker restart dnsmasq
docker restart pkmn-server

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
