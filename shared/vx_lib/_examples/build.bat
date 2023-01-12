@echo off

odin build 00_hello_window.odin -file -out:build/00_hello_window.exe -collection:shared=../../ -vet -strict-style -verbose-errors -warnings-as-errors -define:MODERN_OPENGL=false
odin build 01_hello_triangle.odin -file -out:build/01_hello_triangle.exe -collection:shared=../../ -vet -strict-style -verbose-errors -warnings-as-errors -define:MODERN_OPENGL=false
odin build 02_hello_quad.odin -file -out:build/02_hello_quad.exe -collection:shared=../../ -vet -strict-style -verbose-errors -warnings-as-errors -define:MODERN_OPENGL=false
odin build 03_hello_texture.odin -file -out:build/03_hello_texture.exe -collection:shared=../../ -vet -strict-style -verbose-errors -warnings-as-errors -define:MODERN_OPENGL=false
odin build 04_mandelbrot.odin -file -out:build/04_mandelbrot.exe -collection:shared=../../ -vet -strict-style -verbose-errors -warnings-as-errors -define:MODERN_OPENGL=false
odin build 05_uniformbuffer.odin -file -out:build/05_uniformbuffer.exe -collection:shared=../../ -vet -strict-style -verbose-errors -warnings-as-errors -define:MODERN_OPENGL=false