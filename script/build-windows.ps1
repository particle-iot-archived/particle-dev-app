echo "--> Installing Node.js..."
$env:NVM_HOME = "c:\nvm"
$env:Path += ";$env:NVM_HOME"
#nvm install $env:BUILD_NODE_VERSION
nvm use $env:BUILD_NODE_VERSION $env:NODE_ARCH
$env:Path += ";$env:NVM_HOME\v$env:BUILD_NODE_VERSION"
#npm install -g npm

echo "--> Adding other dependencies..."
choco install patch
$env:Path += ";C:\ProgramData\chocolatey\lib\patch\tools\bin"
choco install git
$env:Path += ";C:\Program Files\Git\bin"
choco install 7zip
$env:Path += ";c:\program files\7-zip"

cd sources
  echo "--> Adding signing key..."
  choco install openssl.light
  $env:Path += ";c:\Program Files\OpenSSL\bin"
  $env:Pwd = (Get-Item -Path ".\" -Verbose).FullName
  $env:ATOM_WIN_CODE_SIGNING_CERT_PATH = "$env:Pwd\build\resources\particle-code-signing-cert.p12"
  $env:ATOM_WIN_CODE_SIGNING_ENC_CERT_PATH = "$env:Pwd\build\resources\particle-code-signing-cert.p12.enc"
  .\script\add-key.cmd

  # Set env
  $env:USERPROFILE = "c:\home"
  $env:Path += ";C:\Windows\SysWOW64\config\systemprofile\.windows-build-tools\python27\"
  $env:Path += ";$env:NVM_HOME\v$env:BUILD_NODE_VERSION\node_modules\.bin"
  $env:Path += ";$env:NVM_HOME\v$env:BUILD_NODE_VERSION\node_modules\npm\bin\node-gyp-bin"
  $env:Path += ";$env:NVM_HOME\v$env:BUILD_NODE_VERSION\windows-build-tools\node_modules\.bin"
  $env:GYP_MSVS_VERSION = "2015"

  echo "--> Starting build..."
  .\script\build.cmd
cd ..

echo "--> Copying artifacts..."
$env:Pwd = (Get-Item -Path ".\" -Verbose).FullName
$sourceDir = "c:\atom-work-dir\out"
$targetDir = "$env:Pwd\artefacts"
Get-ChildItem -Path $sourceDir | Copy-Item -Destination $targetDir -Recurse -Container
