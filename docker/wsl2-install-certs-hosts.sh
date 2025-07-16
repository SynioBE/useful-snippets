# Read variables
eval $(sed "/^#/d" .env)

if [ -z "$DOMAIN" ]; then
    echo "${RED}* DOMAIN not set in .env (did you create .env yet?)${NC}"
    exit 1
fi

if [ -z "$WSL2_HOSTS_FILE" ]; then
    echo "${RED}* WSL2 hosts file not set in .env (did you create .env yet?)${NC}"
    exit 1
fi

# Add self-signed certificates
powershell.exe -command "Import-Certificate -FilePath "docker/certs/nginx-selfsigned.crt" -CertStoreLocation Cert:\CurrentUser\Root"
powershell.exe -command "Import-Certificate -FilePath "docker/certs/nginx-root-ca.pem" -CertStoreLocation Cert:\CurrentUser\Root"

# Add newline to end of hosts file if needed
c=`tail -c 1 $WSL2_HOSTS_FILE`
if [ "$c" != "" ]; then
    echo "" >> $WSL2_HOSTS_FILE
fi

# Add or replace entries in hosts file for these domains
sed -i -E "/$DOMAIN\s+# Added by Synio WP/d" $WSL2_HOSTS_FILE
echo -e "127.0.0.1 $DOMAIN # Added by Synio WP" >> $WSL2_HOSTS_FILE
