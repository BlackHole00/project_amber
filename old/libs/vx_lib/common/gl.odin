package vx_lib_common

import "../platform"
import glsm "../gfx/glstatemanager"
import "../gfx"
import "vendor:glfw"
import gl "vendor:OpenGL"

OPENGL_VERSION_MAJOR :: 4
OPENGL_VERSION_MINOR :: 6

@(private="file")
init_opengl :: proc(handle: glfw.WindowHandle, desc: platform.Window_Descriptor) -> (bool, string) {
    glfw.MakeContextCurrent(handle)

    gl.load_up_to(OPENGL_VERSION_MAJOR, OPENGL_VERSION_MINOR, glfw.gl_set_proc_address)

    if desc.vsync do glfw.SwapInterval(1)

    gfx.gfxprocs_init_with_opengl()
    glsm.init()

    return true, ""
}

@(private="file")
pre_window_init_opengl :: proc() -> (bool, string) {
    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, OPENGL_VERSION_MAJOR)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, OPENGL_VERSION_MINOR)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    gfx.GFX_BACKEND_API = .OpenGL

    return true, ""
}

@(private="file")
post_frame_proc :: proc(handle: glfw.WindowHandle) {
    glfw.SwapBuffers(handle)
}

@(private="file")
close_opengl :: proc() {
    gfx.gfxprocs_free()
    glsm.free()
}

windowcontext_init_with_gl :: proc() {
    platform.windowcontext_init()
    platform.WINDOWCONTEXT_INSTANCE.pre_window_init_proc = pre_window_init_opengl
    platform.WINDOWCONTEXT_INSTANCE.post_window_init_proc = init_opengl
    platform.WINDOWCONTEXT_INSTANCE.post_frame_proc = post_frame_proc
    platform.WINDOWCONTEXT_INSTANCE.close_proc = close_opengl
}