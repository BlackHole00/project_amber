package vx_lib_gfx

import "core:mem"
import gl "vendor:OpenGL"
import "shared:glfw"
import glsm "shared:vx_lib/gfx/glstatemanager"
import core "shared:vx_core"

OpenGL_Context_Descriptor :: struct {
    glfw_window: glfw.WindowHandle,
    vsync: bool,
    version: [2]int,
}

@(private)
Ubo_Bindning_Point_State :: enum byte {
    Available = 0,
    Used      = 1,
}

@(private)
OpenGL_Context :: struct {
    gl_allocator: mem.Allocator,

    ubo_binding_point_states: [dynamic]Ubo_Bindning_Point_State,

    version: [2]int,
}
@(private)
OPENGL_CONTEXT: core.Cell(OpenGL_Context)

opengl_init :: proc(desc: OpenGL_Context_Descriptor, gl_allocator: mem.Allocator) {
    core.cell_init(&OPENGL_CONTEXT)

    glfw.MakeContextCurrent(desc.glfw_window)
    glfw.SwapInterval(desc.vsync ? 1 : 0)

    gl.load_up_to(desc.version[0], desc.version[1], glfw.gl_set_proc_address)
    glsm.init()

    OPENGL_CONTEXT.ubo_binding_point_states = make([dynamic]Ubo_Bindning_Point_State, 0, OPENGL_CONTEXT.gl_allocator)

    OPENGL_CONTEXT.version = desc.version
    OPENGL_CONTEXT.gl_allocator = gl_allocator
}

opengl_deinit :: proc(free_all_mem := false) {
    glsm.deinit()

    delete(OPENGL_CONTEXT.ubo_binding_point_states)
    
    if free_all_mem do mem.free_all(OPENGL_CONTEXT.gl_allocator)
    core.cell_free(&OPENGL_CONTEXT)
}

@(private)
glcontext_get_available_ubo_bind_point :: proc() -> uint {
    i: uint = 0

    for {
        if i >= len(OPENGL_CONTEXT.ubo_binding_point_states) {
            append(&OPENGL_CONTEXT.ubo_binding_point_states, Ubo_Bindning_Point_State.Used)
            return i
        }

        if OPENGL_CONTEXT.ubo_binding_point_states[i] == .Available {
            OPENGL_CONTEXT.ubo_binding_point_states[i] = .Used
            return i
        }

        i += 1
    }

    panic("Unreachable.")
}

@(private)
glcontext_return_ubo_bind_point :: proc(idx: uint) {
    OPENGL_CONTEXT.ubo_binding_point_states[idx] = .Available

    i := len(OPENGL_CONTEXT.ubo_binding_point_states) - 1
    for OPENGL_CONTEXT.ubo_binding_point_states[i] != .Used {
        when ODIN_DEBUG do assert(pop(&OPENGL_CONTEXT.ubo_binding_point_states) != .Used)
        else do pop(&OPENGL_CONTEXT.ubo_binding_point_states)
    }
}
