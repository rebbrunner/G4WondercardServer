###
### Dockerfile migration of https://github.com/EnergyCube/cowfc_installer
### 
### `docker-compose up`
### 
### Open ports listed below
### TCP: 53, 80, 443, 8000, 9000, 9001, 9009, 9002, 9003, 9998, 27500, 27900, 27901, 28910, 29900, 29901, 29920
### UDP: 53
### 
### Admin URL: http://$IP/?page=admin&section=Dashboard
###

ARG ADMIN_USERNAME
ARG ADMIN_PASSWORD

ARG VERSION_OPENSSL="openssl-1.1.1m"
ARG VERSION_HTTPD="httpd-2.4.52"

###
### Build OpenSSL with SSLv3
### info: https://qiita.com/keys/items/61eb02bd7396cda0d548
###
FROM debian/eol:bullseye AS builder_openssl
ARG VERSION_OPENSSL
ARG VERSION_HTTPD

RUN cd / && \
    \
    apt update && apt -y install \
        build-essential \
        curl \
        libapr1-dev \
        libaprutil1-dev \
        libpcre3-dev && \
    \
    cd / && \
    curl https://www.openssl.org/source/$VERSION_OPENSSL.tar.gz -LO && \
    tar xvf $VERSION_OPENSSL.tar.gz && rm $VERSION_OPENSSL.tar.gz && cd $VERSION_OPENSSL && \
    ./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl shared enable-ssl3 enable-ssl3-method enable-weak-ssl-ciphers && make install_sw && make install_ssldirs && \
    \
    cd / && \
    curl http://archive.apache.org/dist/httpd/$VERSION_HTTPD.tar.bz2 -O && \
    tar xvf $VERSION_HTTPD.tar.bz2 && rm $VERSION_HTTPD.tar.bz2 && cd $VERSION_HTTPD && \
    # with this command, you can switch openssl libraries
    echo "/usr/local/openssl/lib" > /etc/ld.so.conf.d/usr.local.openssl.lib.conf && ldconfig && \
    ./configure --enable-ssl --with-ssl=/usr/local/openssl/ && make
###
### Isolate pip from runner
###
FROM python:2.7.18 AS builder_twisted
RUN pip install twisted

###
### pkmn-server
###
FROM debian/eol:bullseye
ARG ADMIN_USERNAME
ARG ADMIN_PASSWORD
ARG VERSION_OPENSSL
ARG VERSION_HTTPD
COPY --from=builder_openssl /$VERSION_OPENSSL /$VERSION_OPENSSL
COPY --from=builder_openssl /$VERSION_HTTPD /$VERSION_HTTPD
COPY --from=builder_twisted /usr/local/lib/python2.7/site-packages /usr/local/lib/python2.7/dist-packages
RUN cd / && \
    \
    #
    # Install requirements
    #
    apt update && apt -y --no-install-recommends install \
        apache2 \
        apt-transport-https \
        ca-certificates \
        curl \
        git \
        libapache2-mod-mono \
        lsb-release \
        mono-xsp \
        net-tools \
        python2.7 \
        python3-software-properties \
        software-properties-common \
        vim && \
    ln -s /usr/bin/python2.7 /usr/bin/python && \
    # Install php7.4
    curl https://packages.sury.org/php/apt.gpg -o /etc/apt/trusted.gpg.d/php.gpg && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list && \
    apt update && apt -y --no-install-recommends install \
        mariadb-server \
        php7.4 \
        php7.4-mysql \
        php7.4-sqlite3 \
        sqlite3 && \
    \
    #
    # Install custom OpenSSL(mod_ssl)
    #
    apt update && apt -y --no-install-recommends install \
        build-essential && \
    cd /$VERSION_OPENSSL && make install_sw && make install_ssldirs && \
    cd /$VERSION_HTTPD && cp modules/ssl/.libs/mod_ssl.so /usr/lib/apache2/modules/ && \
    rm -rf /$VERSION_OPENSSL && rm -rf /$VERSION_HTTPD && \
    # Switch openssl libraries
    # see build section
    echo "/usr/local/openssl/lib" > /etc/ld.so.conf.d/usr.local.openssl.lib.conf && ldconfig && \
    # Remove build dependencies
    apt purge -y build-essential && \
    \
    #
    # Clone CoWFC repositories and install
    #
    cd /var/www/ && \
    git clone --depth 1 https://github.com/EnergyCube/CoWFC.git && \
    git clone --depth 1 https://github.com/EnergyCube/dwc_network_server_emulator.git && \
    # slightly edit config
    sed -i -e "s/db_user = root/db_user = cowfc/g" CoWFC/Web/config.ini && \
    sed -i -e "s/db_pass = passwordhere/db_pass = cowfc/g" CoWFC/Web/config.ini && \
    sed -i -e "s/recaptcha_enabled = 1/recaptcha_enabled = 0/g" CoWFC/Web/config.ini && \
    chmod 777 CoWFC/Web/bans.log && \
    touch dwc_network_server_emulator/gpcm.db && \
    chmod 777 dwc_network_server_emulator/ -R && \
    echo "\npokemondpds\t2\tRwBpAHIAYQBmAGYAZQA_" >> dwc_network_server_emulator/gamestats.cfg && \
    # CoWFC admin page setting
    service mariadb start && \
    echo "CREATE DATABASE cowfc; CREATE USER 'cowfc'@'localhost' IDENTIFIED BY 'cowfc'; GRANT ALL PRIVILEGES ON *.* TO 'cowfc'@'localhost'; FLUSH PRIVILEGES;" | mysql --user=root && \
    mysql --user=root --password= --database=cowfc < CoWFC/SQL/cowfc.sql && \
    echo "INSERT INTO users (Username, Password, Rank) VALUES ('$ADMIN_USERNAME','`/var/www/CoWFC/SQL/bcrypt-hash "$ADMIN_PASSWORD"`','1');" | mysql --user=root --database=cowfc && \
    # Install Websites
    rm -rf html/* && \
    mv CoWFC/Web/* html/ && \
    mv html/config.ini ./ && \
    # Finish CoWFC installation
    touch /etc/.dwc_installed && \
    \
    #
    # Install pkmn-classic-framework
    #
    mkdir -p gamestats2.gs.nintendowifi.net/gts/publish/_PublishedWebsites/gts/ && \
    # Disable capital-case sensitivity
    echo "[mysqld]\nlower_case_table_names=1" >> /etc/mysql/my.cnf && \
    service mariadb restart && \
    echo "CREATE DATABASE gts; CREATE USER 'gts'@'localhost' IDENTIFIED BY 'gts'; GRANT ALL ON *.* TO 'gts'@'localhost';" && \
    \
    #
    # Apache2 config
    #
    cd /etc/apache2/ && \
    # tweaks for suppressing warnings
    echo "ServerName localhost\nHttpProtocolOptions Unsafe LenientMethods Allow0.9" >> apache2.conf && \
    # Enable SSLv3 and week cipher
    sed -i -e "s/SSLCipherSuite HIGH:!aNULL/SSLCipherSuite @SECLEVEL=0:RC4-SHA:RC4-MD5/g" mods-available/ssl.conf && \
    sed -i -e "s/SSLProtocol all -SSLv3/SSLProtocol SSLv3/g" mods-available/ssl.conf && \
    # virtualhost conf from dwc_network_server_emulator
    mv /var/www/dwc_network_server_emulator/tools/apache-hosts/* sites-available/ && \
    sed -i -e 's/ServerAlias "nas.nintendowifi.net"//g' sites-available/nas-naswii-dls1-conntest.nintendowifi.net.conf && \
    sed -i -e 's/ServerAlias "nas.nintendowifi.net, nas.nintendowifi.net"//g' sites-available/nas-naswii-dls1-conntest.nintendowifi.net.conf && \
    # generate custom virtualhost conf
    echo "<VirtualHost *:80>\n        ServerAdmin webmaster@localhost\n        ServerName gamestats2.gs.nintendowifi.net\n        ServerAlias \"gamestats2.gs.nintendowifi.net, gamestats2.gs.nintendowifi.net\"\n        DocumentRoot /var/www/gamestats2.gs.nintendowifi.net\n        MonoAutoApplication disabled\n        MonoServerPath \"/usr/bin/mod-mono-server4\"\n        MonoApplications default \"/:/var/www/gamestats2.gs.nintendowifi.net\"\n        <Location />\n                SetHandler mono\n                MonoSetServerAlias default\n        </Location>\n</VirtualHost>" > sites-available/gamestats2.gs.nintendowifi.net.conf && \
    echo "<VirtualHost *:443>\n        ServerAdmin webmaster@localhost\n        ServerName nas.nintendowifi.net\n        ServerAlias \"nas.nintendowifi.net\"\n        ServerAlias \"nas.nintendowifi.net, nas.nintendowifi.net\"\n        ProxyPreserveHost On\n        ProxyPass / http://127.0.0.1:9000/\n        ProxyPassReverse / http://127.0.0.1:9000/\n        SSLEngine on\n        SSLCertificateFile /etc/apache2/certs/server.crt\n        SSLCertificateKeyFile /etc/apache2/certs/server.key\n        SSLCertificateChainFile /etc/apache2/certs/nwc.crt\n</VirtualHost>" > sites-available/nas.nintendowifi.net.conf && \
    # Apply settings above
    a2dismod mpm_event mod_mono_auto && a2enmod proxy proxy_http "php7.4" ssl && \
    a2ensite *.nintendowifi.net.conf && \
    \
    #
    # Create entry point script
    #
    echo "#!/bin/sh -eu\n\nservice mariadb start\napachectl start\ncd /var/www/dwc_network_server_emulator && python master_server.py" > /entrypoint.sh && chmod +x /entrypoint.sh && \
    \
    #
    # Remove packages
    #
    apt purge -y \
        apt-transport-https \
        git \
        lsb-release \
        net-tools \
        python3-software-properties \
        software-properties-common \
        vim && \
    apt autoremove -y

CMD ["/bin/sh", "/entrypoint.sh"]
