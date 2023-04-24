package vx_lib_platform

import "core:log"
import core "shared:vx_core"

Platform :: struct {
    should_close: bool,

    extensions: [dynamic]Platform_Extension,

    // This list stores the order in which the extensions should be executed
    // (considering dependencies and dependans). Each extension is identified by
    // its index of the extensions list.
    extensions_update_list: []uint,
}
PLATFORM_INSTANCE: core.Cell(Platform)

platform_init :: proc() {
    core.cell_init(&PLATFORM_INSTANCE)

    PLATFORM_INSTANCE.extensions = make([dynamic]Platform_Extension)
}

platform_deinit :: proc() {
    delete(PLATFORM_INSTANCE.extensions)

    if PLATFORM_INSTANCE.extensions_update_list != nil do delete(PLATFORM_INSTANCE.extensions_update_list)

    core.cell_free(&PLATFORM_INSTANCE)
}

platform_request_close :: proc() {
    PLATFORM_INSTANCE.should_close = true
}

platform_register_extension :: proc(extension: Platform_Extension) -> bool {
    if platform_extension_exists(extension.name) {
        log.warn("Extension", extension.name, "already exists. The second instance will not be added")
        return false
    }

    append(&PLATFORM_INSTANCE.extensions, extension)
    return true
}

platform_replace_extension :: proc(extension: Platform_Extension) -> bool {
    if platform_extension_exists(extension.name) {
        log.warn("Extension", extension.name, "does not exists. It cannot be replaced")
        return false
    }

    for ex, i in PLATFORM_INSTANCE.extensions do if ex.name == extension.name {
        PLATFORM_INSTANCE.extensions[i] = extension

        break
    }

    return true
}

platform_extension_exists :: proc(identifier: Platform_Extension_Identifier) -> bool {
    for ex in PLATFORM_INSTANCE.extensions do if ex.name == identifier do return true

    return false
}

platform_get_extension_info :: proc(identifier: Platform_Extension_Identifier) -> Maybe(Platform_Extension_Info) {
    for ex in PLATFORM_INSTANCE.extensions {
        if ex.name == identifier do return Platform_Extension_Info {
            name    = ex.name,
            version = ex.version,
            dependencies = ex.dependencies,
            dependants = ex.dependants,
        }
    }

    return nil
}

platform_run :: proc() {
    log.info("Resolving extensions update list...")
    if !platform_resolve_update_list() {
        panic("Could not resolve the update list!")
    }

    log.info("Generated extensions update list:")
    for extension_id in PLATFORM_INSTANCE.extensions_update_list {
        log.info(args = {
            "\t- ", PLATFORM_INSTANCE.extensions[extension_id].name,
        }, sep = "")
    }

    log.info("Running extensions'init proc")
    // for extension_id in PLATFORM_INSTANCE.extensions_update_list {
    //     if err, msg := PLATFORM_INSTANCE.extensions[extension_id].init_proc(); err != .Ok {
            
    //     }
    // }
}

