package vx_lib_common

import "shared:vx_lib/platform"

vx_lib_init :: proc() {
    platform.platform_init()
    platform_register_default_procs()

    windowcontext_init_with_wgpu()
}

vx_lib_free :: proc() {
    platform.windowcontext_free()
    platform.platform_free()
}
