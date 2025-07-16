# Read variables
eval $(sed "/^#/d" .env)

if [ -z "$DOMAIN" ]; then
    echo "${RED}* Domain not set in .env (did you create .env yet?)${NC}"
    exit 1
fi

# Add or replace entry in hosts file for this domain
sed -i -E "/${DOMAIN}\s+# Added by Synio/d" /etc/hosts
echo -e "127.0.0.1 $DOMAIN # Added by Synio" >> /etc/hosts

# Add newline to end of hosts file if needed
c=`tail -c 1 /etc/hosts`
if [ "$c" != "" ]; then
    echo "" >> /etc/hosts
fi
