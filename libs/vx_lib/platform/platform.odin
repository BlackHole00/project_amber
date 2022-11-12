package vx_lib_platform

import "core:log"
import "shared:vx_lib/core"

Platform_Proc_Result :: enum {
    Ok,
    Warn,
    Fatal,
}

@(private)
Platform_Proc_Record :: struct {
    procedure: proc() -> (ok: Platform_Proc_Result, error_message: string),
    name: string,
}

Platform :: struct {
    started: bool,
    closed: bool,

    starting_procs: [dynamic]Platform_Proc_Record,
    closing_procs: [dynamic]Platform_Proc_Record,
}

PLATFORM_INSTANCE: core.Cell(Platform)

platform_init :: proc() {
    core.cell_init(&PLATFORM_INSTANCE)

    PLATFORM_INSTANCE.starting_procs = make([dynamic]Platform_Proc_Record)
    PLATFORM_INSTANCE.closing_procs = make([dynamic]Platform_Proc_Record)
}

platform_free :: proc() {
    delete(PLATFORM_INSTANCE.starting_procs)
    delete(PLATFORM_INSTANCE.closing_procs)

    core.cell_free(&PLATFORM_INSTANCE)
}

platform_register_starting_proc :: proc(name: string, procedure: proc() -> (ok: Platform_Proc_Result, error_message: string)) {
    append(&PLATFORM_INSTANCE.starting_procs, Platform_Proc_Record {
        procedure,
        name,
    })
}

platform_register_closing_proc :: proc(name: string, procedure: proc() -> (ok: Platform_Proc_Result, error_message: string)) {
    append(&PLATFORM_INSTANCE.closing_procs, Platform_Proc_Record {
        procedure,
        name,
    })
}

platform_register_procs :: proc(name: string,
    starting_proc: proc() -> (ok: Platform_Proc_Result, error_message: string),
    closing_proc: proc() -> (ok: Platform_Proc_Result, error_message: string),
) {
    platform_register_starting_proc(name, starting_proc)
    platform_register_closing_proc(name, closing_proc)
}

platform_start :: proc() {
    when ODIN_DEBUG {
        if PLATFORM_INSTANCE.started {
            log.warn("The platform has already been initialized")
            return
        }
    }

    for record in PLATFORM_INSTANCE.starting_procs {
        err, message := record.procedure()

        switch err {
            case .Ok: log.info("Successfully ran", record.name, "initialization procedure")
            case .Warn: log.warn("Initialization procedure", record.name, "has encountered a non-fatal error: ", message)
            case .Fatal: {
                log.warn("Initialization procedure", record.name, "has encountered a non-fatal error: ", message)
                panic("One initialization procedure failed. Aborting.")
            }
        }
    }

    PLATFORM_INSTANCE.started = true
}

platform_close :: proc() {
    when ODIN_DEBUG {
        if PLATFORM_INSTANCE.closed {
            log.warn("The platform has already been closed")
            return
        }
    }

    for record in PLATFORM_INSTANCE.closing_procs {
        err, message := record.procedure()

        if err == .Ok do log.info("Successfully ran", record.name, "closing procedure")
        else do log.warn("Closing procedure", record.name, "has encountered a non-fatal error: ", message)
    }

    PLATFORM_INSTANCE.closed = true
}
