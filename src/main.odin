package main

import "shared:vx_lib/core"
import "shared:vx_lib/platform"
import "shared:vx_lib/common"

State :: struct {
	a: int,
}
STATE: core.Cell(State)

init :: proc() {
	core.cell_init(&STATE)
}

tick :: proc() {
	input_common()

	STATE.a += 1
}

draw :: proc() {
}

close :: proc() {
	STATE.a += 1
	core.cell_free(&STATE)
}

resize :: proc() {
}

main :: proc() {
	context = core.default_context()
	defer core.free_default_context()

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
	desc.fullscreen = false

	platform.window_init(desc)
	defer platform.window_deinit()

	platform.window_run()
}
