@echo off

odin build src -out:build/main.exe -collection:shared=shared -vet -strict-style -verbose-errors -warnings-as-errors -debug -define:MODERN_OPENGL=true