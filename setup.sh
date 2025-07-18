#!/usr/bin/env bash

UNAMEOUT="$(uname -s)"

# Verify operating system is supported...
case "${UNAMEOUT}" in
    Linux*)             MACHINE=linux;;
    Darwin*)            MACHINE=mac;;
    *)                  MACHINE="UNKNOWN"
esac

if [ "$MACHINE" == "UNKNOWN" ]; then
    echo "Unsupported operating system [$(uname -s)]. Synio supports macOS, Linux, and Windows (WSL2)." >&2
    exit 1
fi

# Determine if stdout is a terminal...
if test -t 1; then
    # Determine if colors are supported...
    ncolors=$(tput colors)

    if test -n "$ncolors" && test "$ncolors" -ge 8; then
        BOLD="$(tput bold)"
        YELLOW="$(tput setaf 3)"
        GREEN="$(tput setaf 2)"
        RED="$(tput setaf 1)"
        NC="$(tput sgr0)"
    fi
fi

trap 'echo "${RED}* Script halted (user pressed CTRL-C?)${NC}"; exit' SIGINT SIGTERM SIGTSTP

if [ ! -f .env ]; then
    echo "${RED}* Cannot find .env file. It is needed to setup the Docker containers. You can find an example .env file here: .env.example${NC}"
    exit 1
fi

# Read environment variables
eval $(sed "/^#/d" .env)

if [ -z "$DOMAIN" ]; then
    echo "${RED}* Domain not set in .env (did you create .env yet?)${NC}"
    exit 1
fi

if [ ! -f bedrock/.env ]; then
    echo "${RED}* Cannot find bedrock/.env file. It is needed to configure the application. You can find an example config file here: bedrock/.env.example${NC}"
    exit 1
fi

if [ ! -f docker/mysql/sqldump/wordpress.sql ]; then
    echo "${RED}* Cannot find docker/mysql/sqldump/wordpress.sql file. It is needed to install the database contents.${NC}"
    exit 1
fi

echo "${GREEN}* Building Docker containers...${NC}"

docker compose build

echo "${GREEN}* Copying self-signed certificates to docker/certs...${NC}"

docker compose run --rm web sh -c "mkdir -p /docker/certs && cp /etc/ssl/certs/nginx-selfsigned.crt /docker/certs/nginx-selfsigned.crt && chmod 666 /docker/certs/nginx-selfsigned.crt"
docker compose run --rm web sh -c "mkdir -p /docker/certs && cp /etc/ssl/certs/nginx-root-ca.pem /docker/certs/nginx-root-ca.pem && chmod 666 /docker/certs/nginx-root-ca.pem"

echo
echo "${GREEN}* Starting Docker containers...${NC}"

docker compose up -d

echo "${GREEN}* Install Composer dependencies${NC}"
echo
docker compose exec -u www-data -w /app/bedrock php composer update
echo

echo "${GREEN}* Generate new security key salts${NC}"
echo
docker compose exec -u www-data -w /app/bedrock php bash -c "wp package install aaemnnosttv/wp-cli-dotenv-command && wp dotenv salts regenerate"
echo

if [[ `uname -r` =~ "WSL2" ]]; then
    echo "${GREEN}* WSL2 Windows environment detected.${NC}"

    # We need Administrator access for some of this... but we don't have it.
    # We can use Start-Process in PowerShell to run a new WSL2 terminal with Administrator privileges.

    echo "${GREEN}  -> Automatically installing self-signed SSL certificates on Windows...${NC}"

    powershell.exe -command "Start-Process -FilePath \"wsl\"" -ArgumentList \"cd `pwd`\; ./docker/wsl2-install-certs.sh\" -Verb RunAs

    echo "${GREEN}  -> Automatically adding domain '${DOMAIN}' to hosts file${NC}"

    powershell.exe -command "Start-Process -FilePath \"wsl\"" -ArgumentList \"cd `pwd`\; ./docker/wsl2-update-hosts.sh\" -Verb RunAs
elif [[ "$MACHINE" == "mac" ]]; then
    echo "${GREEN}* Mac environment detected.${NC}"

    echo "${GREEN}  -> Automatically installing self-signed SSL certificates on Mac using 'sudo'...${NC}"
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain docker/certs/nginx-selfsigned.crt
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain docker/certs/nginx-root-ca.pem

    echo "${GREEN}  -> We will try to automatically add domain '${DOMAIN}' to hosts file using 'sudo'...${NC}"
    sudo ./docker/mac-update-hosts.sh
else
    echo "${RED}* Linux environment detected.${NC}"

    echo "${GREEN}  -> We will try to automatically add domain '${DOMAIN}' to hosts file using 'sudo'...${NC}"

    sudo ./docker/linux-update-hosts.sh

    echo
    echo "${RED}! Please install the self-signed SSL certificate located at /docker/certs into your OS yourself, or simply ignore the SSL certificate warning in your browser.${NC}"
    echo
fi
