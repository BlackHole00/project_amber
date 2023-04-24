package vx_lib_platform

import "core:log"

Platform_Operation_Result :: enum {
    Ok,
    Warn,
    Error,
    Fatal,
}

extension_print_platform_operation_result :: proc(operation: string, extension: Platform_Extension, result: Platform_Operation_Result, msg: string) {
    switch result {
        case .Warn: log.warn("Platform extension", extension.name, "returned a warning during", operation, "procedure:", msg)
        case .Error: log.error("Platform extension", extension.name, "returned an error during", operation, "procedure:", msg)
        case .Fatal: log.fatal("Platform extension", extension.name, "failed with message during", operation, "procedure:", msg)
        case .Ok: {
            if msg != "" do log.info("Platform extension", extension.name, "returned a message during", operation, "procedure:", msg)
        }
    }
}
