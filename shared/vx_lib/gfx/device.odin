package vx_lib_gfx

import "core:log"

Device_Set_Error :: enum {
	Ok,
	Unavaliable_Functionality, // The implementation cannot select the device as it is
	                           // missing this functionality (OpenGL), so the
	                           // implementation is no able to define whatever or not
	                           // the requirements are achieved. It is not an error.
	Impossible_Functionality,  // The requirements are not possible to be achieved by
							   // by the current implementation (Headless rendering on
							   // OpenGL).
	No_Devices,       // No devices of the device_type defined have been found.
	// ... To add regarding limits
}

Device_Type :: enum {
    Software,
    Power_Efficient,
    Performance,
	Unknown,
}

Device_Requirements :: struct {
	device_type: Device_Type,
	headless: bool,

	// limits to be added in the future
}

Device_Info :: struct {
	device_name: string,
	driver_info: string,
	api_info: string,

	device_type: Device_Type,
	headless: bool,

	// limits to be added in the future
}

// Tries and finds the best device that satisfied the requirements. Returns whatever 
// or not the device has been found and, eventually set.
device_try_set :: proc(requirements: Device_Requirements) -> Device_Set_Error {
    error := CONTEXT_INSTANCE.device_check_requirements(requirements)
	if (error == .Ok) do CONTEXT_INSTANCE.device_set(requirements)

	return error
}

// Sets the best device found whatever or not it satisfies the requirements. It is
// necessary to use for the implementations that return `.Unavaliable_Functionality` 
// from `device_try_set`.
device_set :: proc(requirements: Device_Requirements) -> Device_Set_Error {
	context.logger = CONTEXT_INSTANCE.logger

    error := CONTEXT_INSTANCE.device_check_requirements(requirements)
	if (CONTEXT_INSTANCE.debug && error != .Ok) do log.warn("Force set of the device with error", error)

	CONTEXT_INSTANCE.device_set(requirements)

	return error
}

device_get_info :: proc() -> Maybe(Device_Info) {
    return CONTEXT_INSTANCE.device_get_info()
}

deviceinfo_free :: proc(info: Maybe(Device_Info)) {
	if (info == nil) do return

    CONTEXT_INSTANCE.deviceinfo_free(info.?)
}

// Tries and creates a swapchain using the provided descriptor.
device_try_set_swapchain :: proc(descriptor: Swapchain_Descriptor) -> Swapchain_Set_Error {
    error := CONTEXT_INSTANCE.device_check_swapchain_descriptor(descriptor)
	if (error == .Ok) do CONTEXT_INSTANCE.device_set_swapchain(descriptor)

	return error
}

// Creates a best-effort swapchain trying to keep its properties as close as the
// ones provided by the descriptor. It is necessary to use for the implementations 
// that return `.Unavaliable_Functionality` from `device_try_set_swapchain`.
device_set_swapchain :: proc(descriptor: Swapchain_Descriptor) -> Swapchain_Set_Error {
	context.logger = CONTEXT_INSTANCE.logger

    error := CONTEXT_INSTANCE.device_check_swapchain_descriptor(descriptor)
	if (CONTEXT_INSTANCE.debug && error != .Ok) do log.warn("Force set of the swapchain with error", error)

	CONTEXT_INSTANCE.device_set_swapchain(descriptor)

	return error
}
