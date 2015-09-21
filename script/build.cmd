%~dp0\set-variables.cmd
@IF EXIST "%~dp0\node.exe" (
  "%~dp0\node.exe"  "%~dp0\build" %*
) ELSE (
  node  "%~dp0\build" %*
)
