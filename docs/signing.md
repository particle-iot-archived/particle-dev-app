## Signing for Windows

This repo contains `aes-256-cbc` encrypted signing certificate called `particle-code-signing-cert.p12.enc`. To decrypt it you need to know `ENCRYPTION_SECRET`.

### Encrypting a new certificate

As certificate expires after a year it's nessesary to update the encrypted version using:

`$ openssl aes-256-cbc -k $ENCRYPTION_SECRET -in particle-code-signing-cert.p12 -out particle-code-signing-cert.p12.enc -e -a`
