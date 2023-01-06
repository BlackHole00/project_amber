package main

import "core:log"
import "shared:vx_lib/platform"
import "shared:vx_lib/common"
import core "shared:vx_core"

State :: struct {
	counter: uint,
}
STATE: core.Cell(State)

init :: proc() {
	core.cell_init(&STATE)

    log.info("Initialization procedure. Since everything is ODIN is zero-initialized, it is not necessary to initialized STATE.counter, since it is already 0.")
}

tick :: proc() {
    log.info("Incrementing the counter.")
    STATE.counter += 1
}

draw :: proc() {
    log.info("Counter is", STATE.counter)
}

close :: proc() {
    log.info("Exited with counter =", STATE.counter)
	
    core.cell_free(&STATE)
}

main :: proc() {
	context = core.default_context()
	defer core.free_default_context()

    // vx_lib_init() initializes the platform and registers GLFW for 
    // initialization.
	common.vx_lib_init()
    // vx_lib_free() frees the platform.
	defer common.vx_lib_free()

    // platform_start() initializes the libraries (like GLFW).
	platform.platform_start()
    // platform_close() deinitializes the libraries.
	defer platform.platform_close()

	desc: platform.Window_Descriptor
    // Configuration of basic information.
	desc.title = "Window"
	desc.size = { 640, 480 }
	desc.decorated = true
	desc.show_fps_in_title = true
	desc.vsync = false
	desc.resizable = false
	desc.fullscreen = false

    // Configuration of the callbacks. 
    desc.init_proc = init
	desc.logic_proc = tick
	desc.draw_proc = draw
	desc.close_proc = close

	platform.window_init(desc)
	defer platform.window_deinit()

	platform.window_run()
}