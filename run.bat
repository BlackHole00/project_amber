@echo off
odin run src -out:build/main.exe -collection:vx_lib=libs/vx_lib -vet -strict-style -verbose-errors -warnings-as-errors -debug