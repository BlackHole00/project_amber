package vx_lib_common

import "shared:glfw"
import "shared:vx_lib/platform"

@(private)
GLFW_INITIALIZED := false

// Registers only GLFW for now.
platform_register_default_procs :: proc() {
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

    platform.platform_register_procs("GLFW", glfw_init_proc, glfw_terminate_proc)
}