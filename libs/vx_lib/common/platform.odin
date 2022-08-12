package vx_lib_common

import "../platform"

platform_register_default_procs :: proc() {
    platform.platform_register_procs("GLFW", glfw_init_proc, glfw_terminate_proc)
}