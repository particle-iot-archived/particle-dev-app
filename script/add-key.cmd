openssl aes-256-cbc -k %ENCRYPTION_SECRET% -md md5 -in %ATOM_WIN_CODE_SIGNING_ENC_CERT_PATH% -out %ATOM_WIN_CODE_SIGNING_CERT_PATH% -a -d
certutil -p %ATOM_WIN_CODE_SIGNING_CERT_PASSWORD% -user -importpfx .\build\resources\particle-code-signing-cert.p12 NoRoot
