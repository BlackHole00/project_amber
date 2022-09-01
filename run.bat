@echo off

if exist "libs\vx_lib\common\metal.odin" ren libs\vx_lib\common\metal.odin metal.disabled
if exist "libs\vx_lib\gfx\buffer_metalimpl.odin" ren libs\vx_lib\gfx\buffer_metalimpl.odin buffer_metalimpl.disabled
if exist "libs\vx_lib\gfx\pipeline_metalimpl.odin" ren libs\vx_lib\gfx\pipeline_metalimpl.odin pipeline_metalimpl.disabled
if exist "libs\vx_lib\gfx\metal_context.odin" ren libs\vx_lib\gfx\metal_context.odin metal_context.disabled
if exist "libs\vx_lib\platform\cocoa.odin" ren libs\vx_lib\platform\cocoa.odin cocoa.disabled

odin run src -out:build/main.exe -collection:vx_lib=libs/vx_lib -collection:project_amber=libs/project_amber -vet -strict-style -verbose-errors -warnings-as-errors -debug

if exist "libs\vx_lib\common\metal.disabled" ren libs\vx_lib\common\metal.disabled metal.odin
if exist "libs\vx_lib\gfx\buffer_metalimpl.disabled" ren libs\vx_lib\gfx\buffer_metalimpl.disabled buffer_metalimpl.odin
if exist "libs\vx_lib\gfx\pipeline_metalimpl.disabled" ren libs\vx_lib\gfx\pipeline_metalimpl.disabled pipeline_metalimpl.odin
if exist "libs\vx_lib\gfx\metal_context.disabled" ren libs\vx_lib\gfx\metal_context.disabled metal_context.odin
if exist "libs\vx_lib\platform\cocoa.disabled" ren libs\vx_lib\platform\cocoa.disabled cocoa.odin