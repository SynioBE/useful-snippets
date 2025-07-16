# Read variables
eval $(sed "/^#/d" .env)

if [ -z "$DOMAIN" ]; then
    echo "${RED}* Domain not set in .env (did you create .env yet?)${NC}"
    exit 1
fi

if [ -z "$WSL2_HOSTS_FILE" ]; then
    echo "${RED}* WSL2 hosts file not set in .env (did you create .env yet?)${NC}"
    exit 1
fi

# Add or replace entry in hosts file for this domain
sed -i -E "/$DOMAIN\s+# Added by Synio/d" $WSL2_HOSTS_FILE
echo -e "127.0.0.1 $DOMAIN # Added by Synio" >> $WSL2_HOSTS_FILE

# Add newline to end of hosts file if needed
c=`tail -c 1 $WSL2_HOSTS_FILE`
if [ "$c" != "" ]; then
    echo "" >> $WSL2_HOSTS_FILE
fi
