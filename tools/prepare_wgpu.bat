@echo off

call .\gen_wgpu_bindings.bat

cd ..\libs\wgpu\wgpu-native
make package
copy .\target\debug\wgpu_native.dll.lib ..\wgpu_native.lib
copy .\target\debug\wgpu_native.dll ..\..\..\build\wgpu_native.dll

cd ..\..\..\tools

echo DONE!