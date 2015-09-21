@type .atomrc | powershell -Command "$input | ForEach-Object { $_ -replace \"export \", \"@SET \" }" > atomrc.cmd
@call .\atomrc.cmd
@IF EXIST "%~dp0\node.exe" (
  "%~dp0\node.exe"  "%~dp0\build" %*
) ELSE (
  node  "%~dp0\build" %*
)
