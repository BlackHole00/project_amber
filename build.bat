@echo off
odin build src -out:build/main.exe -collection:vx_lib=libs/vx_lib -collection:project_amber=libs/project_amber -vet -strict-style -verbose-errors -warnings-as-errors -debug