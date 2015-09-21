type .atomrc | powershell -Command "$input | ForEach-Object { $_ -replace \"export \", \"SET \" }" > atomrc.cmd
.\atomrc.cmd
