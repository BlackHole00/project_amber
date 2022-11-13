package vx_lib_core

import "core:os"
import "core:log"
import "core:mem"
import "core:runtime"

@(private)
DEFAULT_CONTEXT_INSTANCE: runtime.Context
@(private)
CONTEXT_VALID := false
@(private)
CONTEXT_LOG_FILE: os.Handle
@(private)
CONTEXT_TRACKING_ALLOCATOR: mem.Tracking_Allocator

default_context :: proc() -> runtime.Context {
    if !CONTEXT_VALID do init_default_context()

    return DEFAULT_CONTEXT_INSTANCE
}

init_default_context :: proc() {
    DEFAULT_CONTEXT_INSTANCE = runtime.default_context()

    file, ok := os.open("log.txt", os.O_CREATE | os.O_WRONLY)

	logger: log.Logger = ---
	if ok != 0 do logger = log.create_console_logger()
	else do logger = log.create_multi_logger(
		log.create_console_logger(),
		log.create_file_logger(file),
	)
	DEFAULT_CONTEXT_INSTANCE.logger = logger
    CONTEXT_LOG_FILE = file
	if ok != 0 do log.warn("Could not open the log file!")

	mem.tracking_allocator_init(&CONTEXT_TRACKING_ALLOCATOR, DEFAULT_CONTEXT_INSTANCE.allocator)
	DEFAULT_CONTEXT_INSTANCE.allocator = mem.tracking_allocator(&CONTEXT_TRACKING_ALLOCATOR)

    CONTEXT_VALID = true
}

free_default_context :: proc() {
    if !CONTEXT_VALID do return

    if CONTEXT_LOG_FILE != 0 do os.close(CONTEXT_LOG_FILE)
    mem.tracking_allocator_destroy(&CONTEXT_TRACKING_ALLOCATOR)

    CONTEXT_VALID = false
}