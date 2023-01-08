package vx_lib_common

import "shared:vx_lib/platform"

// Initializes the platform (requesting also the GLFW initialization) and the 
// platform.Window_Context (initializing OpenGL).
vx_lib_init :: proc() {
    platform.platform_init()
    platform_register_default_procs()

    windowcontext_init_with_gl()
}

// Frees the platform and the platform.Window_Context. Must be called after the
// main loop.
vx_lib_free :: proc() {
    platform.windowcontext_free()
    platform.platform_free()
}
