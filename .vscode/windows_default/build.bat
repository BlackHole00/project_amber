@echo off

if exist "libs\vx_lib\platform\cocoa.odin" ren libs\vx_lib\platform\cocoa.odin cocoa.disabled

odin build src -out:build/main.exe -collection:shared=libs -vet -strict-style -verbose-errors -warnings-as-errors -debug

if exist "libs\vx_lib\platform\cocoa.disabled" ren libs\vx_lib\platform\cocoa.disabled cocoa.odin