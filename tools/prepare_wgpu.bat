@echo off

call .\gen_wgpu_bindings.bat

cd ..\libs\wgpu\wgpu-native
make package
copy .\target\debug\wgpu_native.lib ..\wgpu_native.lib

echo DONE!