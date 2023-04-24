package vx_lib_gfx

import core "shared:vx_core"
import plt "shared:vx_lib/platform"
import wnd "shared:vx_lib/window"

GFXSUPPORT_EXTENSION :: plt.Platform_Extension {
    name = "vx_lib.gfx.support",
    version = core.Version { 0, 1, 0 },

    init_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        if !core.cell_is_valid(GFXDESCRIPTOR_INSTANCE) {
            return .Fatal, "Gfx descriptor invalid!"
        }
        if !core.cell_is_valid(BACKENDINITIALIZER_INSTANCE) {
            return .Fatal, "Backend initializer invalid!"
        }

        pre_window_init(GFXDESCRIPTOR_INSTANCE.ptr^, BACKENDINITIALIZER_INSTANCE.ptr^)

        return .Ok, ""
    },

    dependencies = { "vx_lib.depencences.glfw" },
    dependants = { "vx_lib.window" },
}

GFX_EXTENSION :: plt.Platform_Extension {
    name = "vx_lib.gfx",
    version = core.Version { 0, 1, 0 },

    init_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        if !core.cell_is_valid(BACKENDUSERINITIALIZATIONDATA_INSTANCE) {
            return .Fatal, "Backend user initialization data invalid!"
        }

        init(wnd.windowhelper_get_raw_handle(), BACKENDUSERINITIALIZATIONDATA_INSTANCE.ptr^)

        return .Ok, ""
    },
    postframe_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        post_frame(wnd.windowhelper_get_raw_handle())

        return .Ok, ""
    },
    deinit_proc = proc() -> (result: plt.Platform_Operation_Result, message: string) {
        deinit()

        core.cell_free(&GFXDESCRIPTOR_INSTANCE)
        core.cell_free(&BACKENDINITIALIZER_INSTANCE)
        core.cell_free(&BACKENDUSERINITIALIZATIONDATA_INSTANCE)

        return .Ok, ""
    },

    dependencies = { "vx_lib.gfx.support", "vx_lib.window" },
    dependants = { },
}

@(private)
GFXDESCRIPTOR_INSTANCE: core.Cell(Gfx_Descriptor)

@(private)
BACKENDINITIALIZER_INSTANCE: core.Cell(Backend_Initializer)

@(private)
BACKENDUSERINITIALIZATIONDATA_INSTANCE: core.Cell(Backend_User_Initialization_Data)

set_gfxdescriptor :: proc(descriptor: Gfx_Descriptor) {
    if !core.cell_is_valid(GFXDESCRIPTOR_INSTANCE) {
        core.cell_init(&GFXDESCRIPTOR_INSTANCE, descriptor)

        return
    }

    GFXDESCRIPTOR_INSTANCE.ptr^ = descriptor
}

set_backendinitializer :: proc(initializer: Backend_Initializer) {
    if !core.cell_is_valid(BACKENDINITIALIZER_INSTANCE) {
        core.cell_init(&BACKENDINITIALIZER_INSTANCE, initializer)

        return
    }

    BACKENDINITIALIZER_INSTANCE.ptr^ = initializer
}

set_backenduserinitializationdata :: proc(data: Backend_User_Initialization_Data) {
    if !core.cell_is_valid(BACKENDUSERINITIALIZATIONDATA_INSTANCE) {
        core.cell_init(&BACKENDUSERINITIALIZATIONDATA_INSTANCE, data)

        return
    }

    BACKENDUSERINITIALIZATIONDATA_INSTANCE.ptr^ = data
}