package vx_lib_platform

import "core:log"
import core "shared:vx_core"

// A platform callback. It will be called at the initializaion if the procedure 
// has been registered with platform_register_starting_proc() or it will be
// called at the deinitialization it platform_register_closing_proc() has been
// used.  
// It must return a result of the operation and an eventual error message 
// (should be "" if no error has been encountered). It the result is .Fatal the
// application will panic.
Platform_Proc :: #type proc() -> (ok: Platform_Proc_Result, error_message: string)

Platform_Proc_Result :: enum {
    Ok,
    Warn,
    Fatal,
}

@(private)
Platform_Proc_Record :: struct {
    procedure: Platform_Proc,
    name: string,
}

// SINGLETON - This struct is used to intialize the platform and all its 
// components and libraries before the window initialization.
Platform :: struct {
    started: bool,
    closed: bool,

    // Contains the procedure that will be called when the platform needs to be
    // initialized.
    starting_procs: [dynamic]Platform_Proc_Record,

    // Contains the procedure that will be called when the platform needs to be
    // deinitialized.
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

// Adds a function that will be called at the initialization.
platform_register_starting_proc :: proc(name: string, procedure: Platform_Proc) {
    append(&PLATFORM_INSTANCE.starting_procs, Platform_Proc_Record {
        procedure,
        name,
    })
}

// Adds a function that will be called at the deinitialization.
platform_register_closing_proc :: proc(name: string, procedure: Platform_Proc) {
    append(&PLATFORM_INSTANCE.closing_procs, Platform_Proc_Record {
        procedure,
        name,
    })
}

platform_register_procs :: proc(name: string,
    starting_proc: Platform_Proc,
    closing_proc: Platform_Proc,
) {
    platform_register_starting_proc(name, starting_proc)
    platform_register_closing_proc(name, closing_proc)
}

// Initializes all the libaries requested.
platform_start :: proc() {
    when ODIN_DEBUG {
        if PLATFORM_INSTANCE.started {
            log.warn("The platform has already been initialized")
            return
        }
    }

    log.info("Initializating the platform.")
    for record in PLATFORM_INSTANCE.starting_procs {
        log.info("Running", record.name, "initialization.")
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
    log.info("Successfully initializated the platform.")

    PLATFORM_INSTANCE.started = true
}

// Deinitializes all the libaries requested.
platform_close :: proc() {
    when ODIN_DEBUG {
        if PLATFORM_INSTANCE.closed {
            log.warn("The platform has already been closed")
            return
        }
    }

    log.info("Deinitializing the platform.")
    had_errors := false
    for record in PLATFORM_INSTANCE.closing_procs {
        log.info("Running", record.name, "deinitialization.")
        err, message := record.procedure()

        if err == .Ok do log.info("Successfully ran", record.name, "closing procedure")
        else {
            log.warn("Closing procedure", record.name, "has encountered an error: ", message)
            had_errors = true
        }
    }

    if had_errors do log.warn("Deinitializated the platform with errors.")
    else do log.info("Successfullty deinitializated the platform.")

    PLATFORM_INSTANCE.closed = true
}
