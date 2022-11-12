package vx_lib_common

import "vx_lib:platform"

vx_lib_init :: proc() {
    platform.platform_init()
    platform_register_default_procs()

    windowcontext_init_empty()
}

vx_lib_free :: proc() {
    platform.windowcontext_free()
    platform.platform_free()
}

windowcontext_init_empty :: proc() {
    platform.windowcontext_init(platform.Window_Context_Descriptor {})
}
