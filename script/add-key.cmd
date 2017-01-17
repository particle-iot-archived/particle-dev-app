openssl aes-256-cbc -k %ENCRYPTION_SECRET% -in .\build\resources\particle-code-signing-cert.p12.enc -out .\build\resources\particle-code-signing-cert.p12 -d -a
certutil -p %KEY_PASSWORD% -user -importpfx .\build\resources\particle-code-signing-cert.p12 NoRoot
