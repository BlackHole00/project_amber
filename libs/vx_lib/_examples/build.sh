odin build 00_hello_window.odin -file -out:build/00_hello_window.app -collection:shared=../../ -vet -strict-style -verbose-errors -warnings-as-errors -define:MODERN_OPENGL=false
odin build 01_hello_triangle.odin -file -out:build/01_hello_triangle.app -collection:shared=../../ -vet -strict-style -verbose-errors -warnings-as-errors -define:MODERN_OPENGL=false
odin build 02_hello_quad.odin -file -out:build/02_hello_quad.app -collection:shared=../../ -vet -strict-style -verbose-errors -warnings-as-errors -define:MODERN_OPENGL=false
odin build 03_hello_texture.odin -file -out:build/03_hello_texture.app -collection:shared=../../ -vet -strict-style -verbose-errors -warnings-as-errors -define:MODERN_OPENGL=false