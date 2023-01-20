package vx_lib_gfx_GL4

import "core:mem"
import "shared:glfw"
import gl "vendor:OpenGL"
import glsm "shared:vx_lib/gfx/glstatemanager"

opengl_init :: proc(desc: Context_Descriptor, gl_allocator: mem.Allocator) {
    glfw.MakeContextCurrent(desc.glfw_window)
    glfw.SwapInterval(desc.vsync ? 1 : 0)

    gl.load_up_to(desc.version[0], desc.version[1], glfw.gl_set_proc_address)
    glsm.init()

    CONTEXT.ubo_binding_point_states = make([dynamic]Ubo_Bindning_Point_State, 0, CONTEXT.gl_allocator)

    CONTEXT.gl_version = desc.version
    CONTEXT.gl_allocator = gl_allocator
}

opengl_deinit :: proc() {
    glsm.deinit()

    delete(CONTEXT.ubo_binding_point_states)
}

@(private)
glcontext_get_available_ubo_bind_point :: proc() -> uint {
    i: uint = 0

    for {
        if i >= len(CONTEXT.ubo_binding_point_states) {
            append(&CONTEXT.ubo_binding_point_states, Ubo_Bindning_Point_State.Used)
            return i
        }

        if CONTEXT.ubo_binding_point_states[i] == .Available {
            CONTEXT.ubo_binding_point_states[i] = .Used
            return i
        }

        i += 1
    }

    panic("Unreachable.")
}

@(private)
glcontext_return_ubo_bind_point :: proc(idx: uint) {
    CONTEXT.ubo_binding_point_states[idx] = .Available

    i := len(CONTEXT.ubo_binding_point_states) - 1
    for CONTEXT.ubo_binding_point_states[i] != .Used {
        when ODIN_DEBUG do assert(pop(&CONTEXT.ubo_binding_point_states) != .Used)
        else do pop(&CONTEXT.ubo_binding_point_states)
    }
}
