package main

import "core:log"
import "core:os"
import "core:mem"
import "vx_lib:core"
import "vx_lib:platform"
import "vx_lib:common"

State :: struct {
}
STATE: core.Cell(State)

init :: proc() {
	core.cell_init(&STATE)
}

tick :: proc() {
	input_common()
}

draw :: proc() {
}

close :: proc() {
	core.cell_free(&STATE)
}

resize :: proc() {
}

main :: proc() {
	file, ok := os.open("log.txt", os.O_CREATE | os.O_WRONLY)

	logger: log.Logger = ---
	if ok != 0 do logger = log.create_console_logger()
	else do logger = log.create_multi_logger(
		log.create_console_logger(),
		log.create_file_logger(file),
	)
	context.logger = logger
	if ok != 0 do log.warn("Could not open the log file!")

	ta: mem.Tracking_Allocator = ---
	mem.tracking_allocator_init(&ta, context.allocator)
	defer mem.tracking_allocator_destroy(&ta)
	context.allocator = mem.tracking_allocator(&ta)

	common.vx_lib_init()
	defer common.vx_lib_free()

	platform.platform_start()
	defer platform.platform_close()

	desc: platform.Window_Descriptor
	desc.title = "Window"
	desc.size = { 640, 480 }
	desc.decorated = true
	desc.show_fps_in_title = true
	desc.init_proc = init
	desc.logic_proc = tick
	desc.draw_proc = draw
	desc.resize_proc = resize
	desc.close_proc = close
	desc.vsync = false
	desc.resizable = false

	platform.window_init(desc)
	defer platform.window_deinit()

	platform.window_run()
}
