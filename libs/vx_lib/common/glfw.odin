package vx_lib_common

import "../platform"
import "vendor:glfw"

@(private)
GLFW_INITIALIZED := false

glfw_init_proc :: proc() -> (ok: platform.Platform_Proc_Result, error_message: string) {
    if GLFW_INITIALIZED do return .Warn, "GLFW is already initialized"
    if !(bool)(glfw.Init()) do return .Fatal, "GLFW has failed to initialize"

    GLFW_INITIALIZED = true

    return .Ok, ""
}

glfw_terminate_proc :: proc() -> (ok: platform.Platform_Proc_Result, error_message: string) {
    if !GLFW_INITIALIZED do return .Warn, "GLFW has already been initialized"

    glfw.Terminate()

    return .Ok, ""
}
