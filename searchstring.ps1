#search path for string in files
cls
#Get-ChildItem -recurse "C:\work\*.txt" | Where-Object { $_ | Select-String -Pattern "LOGONDATA" }
#Get-ChildItem -recurse "D:\SSS1\work\Samples\*.js" | Where-Object { $_ | Select-String -Pattern "sessionstorage" }

#intercept authentication
#Get-ChildItem -recurse "D:\SSS1\work\Samples\ang2\*.ts" | Where-Object { $_ | Select-String -Pattern "interceptors" }
#Get-ChildItem -recurse "D:\SSS1\work\Samples\ang15\*.js" | Where-Object { $_ | Select-String -Pattern "interceptors" }
Get-ChildItem -recurse "D:\SSS1\work\Samples\NODEJS\*.js" | Where-Object { $_ | Select-String -Pattern "interceptors" }
#Get-ChildItem -recurse "D:\SSS1\work\Samples\React\*.js" | Where-Object { $_ | Select-String -Pattern "localStorage" }


#Get-ChildItem -recurse "D:\SSS1\work\Samples\ang2\*.html" | Where-Object { $_ | Select-String -Pattern "sessionStorage" }
#Get-ChildItem -recurse "D:\SSS1\work\Samples\ang15\*.js" | Where-Object { $_ | Select-String -Pattern "localStorage" }
#Get-ChildItem -recurse "D:\SSS1\work\Samples\NODEJS\*.js" | Where-Object { $_ | Select-String -Pattern "localStorage" }
