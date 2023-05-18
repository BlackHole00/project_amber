package vx_lib_gfx

import core "shared:vx_core"
import plt "shared:vx_lib/platform"
import wnd "shared:vx_lib/window"

GFXSUPPORT_EXTENSION :: plt.Platform_Extension {
    name = "vx_lib.gfx.support",
    version = core.Version { 0, 1, 0 },

    init_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        gfx_pre_window_init()

        return .Ok, ""
    },

    dependencies = { "vx_lib.depencences.glfw" },
    dependants = { "vx_lib.window" },
}

GFX_EXTENSION :: plt.Platform_Extension {
    name = "vx_lib.gfx",
    version = core.Version { 0, 1, 0 },

    init_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        gfx_init(wnd.windowhelper_get_raw_handle())

        return .Ok, ""
    },
    postframe_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        gfx_post_frame(wnd.windowhelper_get_raw_handle())

        return .Ok, ""
    },
    deinit_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        gfx_deinit()

        return .Ok, ""
    },

    dependencies = { "vx_lib.gfx.support", "vx_lib.window" },
    dependants = { },
}
