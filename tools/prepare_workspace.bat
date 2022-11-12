@echo off

cd ..
copy .\.vscode\windows_default\launch.json .\.vscode\launch.json
copy .\.vscode\windows_default\tasks.json .\.vscode\tasks.json
copy .\.vscode\windows_default\ols.json .\ols.json
copy .\.vscode\windows_default\run.bat .\run.bat
copy .\.vscode\windows_default\build.bat .\build.bat

cd tools

echo DONE!