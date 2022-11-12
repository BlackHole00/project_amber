@echo off

odin run gen_wgpu_bindings.odin -file -out:build/gen_wgpu_bindings_tool.exe
del build\gen_wgpu_bindings_tool.exe