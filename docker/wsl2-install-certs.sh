# Add self-signed certificates
powershell.exe -command "Import-Certificate -FilePath "docker/certs/nginx-selfsigned.crt" -CertStoreLocation Cert:\CurrentUser\Root"
powershell.exe -command "Import-Certificate -FilePath "docker/certs/nginx-root-ca.pem" -CertStoreLocation Cert:\CurrentUser\Root"
