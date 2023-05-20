package vx_lib_gfx

Swapchain_Set_Error :: enum {
	Ok,
	Unavaliable_Functionality, // The implementation cannot select the device as it is
	                           // missing this functionality (OpenGL), so the
	                           // implementation is no able to define whatever or not
	                           // the requirements are achieved. It is not an error.
	Impossible_Functionality,  // The requirements are not possible to be achieved by
							   // by the current implementation (Headless rendering on
							   // OpenGL).
	Illegal_Size,
	Illegal_Format,
	Illegal_Refresh_Rate,
	Illegal_Multisample,
	// ... To add regarding limits
}

Present_Mode :: enum {
	Vsync,      // Waits for vsync.
	Immediate,  // No vsync
}

Swapchain_Descriptor :: struct {
	present_mode: Present_Mode,
	size: [2]uint,
	format: Image_Format,
	fullscreen: bool,
}

Swapchain_Info :: Swapchain_Descriptor

// Returns nil if the swapchain has not been already created or if the backend cannot
// provide the necessary information.
swapchain_get_info :: proc() -> Maybe(Swapchain_Info) {
    return CONTEXT_INSTANCE.swapchain_get_info()
}

// Returns false if the resize was not successfull.
swapchain_resize :: proc(size: [2]uint) -> bool {
    return CONTEXT_INSTANCE.swapchain_resize(size)
}

// Returns nil if the swapchain has not been initialized.
swapchain_get_rendertarget :: proc() -> Render_Target {
    return CONTEXT_INSTANCE.swapchain_get_rendertarget()
}

