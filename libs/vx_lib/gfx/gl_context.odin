package vx_lib_gfx

import "core:mem"
import gl "vendor:OpenGL"
import "vendor:glfw"
import glsm "shared:vx_lib/gfx/glstatemanager"
import core "shared:vx_core"

OpenGL_Context_Descriptor :: struct {
    glfw_window: glfw.WindowHandle,
    vsync: bool,
    version: [2]int,
}

OpenGL_Context :: struct {
    gl_allocator: mem.Allocator,

    version: [2]int,
}
OPENGL_CONTEXT: core.Cell(OpenGL_Context)

opengl_init :: proc(desc: OpenGL_Context_Descriptor, gl_allocator: mem.Allocator) {
    core.cell_init(&OPENGL_CONTEXT)

    glfw.MakeContextCurrent(desc.glfw_window)
    glfw.SwapInterval(desc.vsync ? 1 : 0)

    gl.load_up_to(desc.version[0], desc.version[1], glfw.gl_set_proc_address)
    glsm.init()

    OPENGL_CONTEXT.version = desc.version
    OPENGL_CONTEXT.gl_allocator = gl_allocator
}

opengl_deinit :: proc(free_all_mem := false) {
    glsm.deinit()
    
    if free_all_mem do mem.free_all(OPENGL_CONTEXT.gl_allocator)
    core.cell_free(&OPENGL_CONTEXT)
}