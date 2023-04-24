package vx_lib_dependences

import "shared:glfw"
import plt "shared:vx_lib/platform"

GLFW_EXTENSION :: plt.Platform_Extension {
    name = "vx_lib.depencences.glfw",
    version = { 3, 3, 8 },

    init_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        if glfw.Init() == 0 {
            return .Fatal, "Could not initialize glfw."
        }

        return .Ok, ""
    },
    deinit_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        glfw.Terminate()

        return .Ok, ""
    },

    dependencies = {},
    dependants = {},
}