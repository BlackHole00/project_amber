package vx_lib_window

import core "shared:vx_core"
import plt "shared:vx_lib/platform"

WINDOW_EXTENSION :: plt.Platform_Extension {
    name = "vx_lib.window",
    version = core.Version { 0, 1, 0 },

    init_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        return window_init()
    },
    preframe_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        window_preframe()

        return .Ok, ""
    },
    postframe_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        window_postframe()

        return .Ok, ""
    },
    deinit_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        window_deinit()

        core.cell_free(&WINDOW_DESCRIPTOR_INSTANCE)

        return .Ok, ""
    },

    dependencies = { "vx_lib.depencences.glfw" },
    dependants = {},
}
