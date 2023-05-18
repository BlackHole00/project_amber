package vx_lib_gfx

import "core:log"

Device_Type :: enum {
    Software,
    Power_Efficient,
    Performance,
	Unknown,
}

Device_Info :: struct {
	device_name: string,
	driver_info: string,
	api_info: string,

	device_type: Device_Type,

	// limits to be added in the future
}

Device_Info_List :: []Device_Info

get_deviceinfolist :: proc() -> Device_Info_List {
	return CONTEXT_INSTANCE.get_deviceinfolist()
}

// Return the device info. Return nil if the device has not been chosen yet.
device_get_info :: proc() -> Maybe(Device_Info) {
	return CONTEXT_INSTANCE.device_get_info()
}

deviceinfolist_free :: proc(list: Device_Info_List) {
	CONTEXT_INSTANCE.deviceinfolist_free(list)
}

deviceinfo_free :: proc(info: Device_Info) {
    CONTEXT_INSTANCE.deviceinfo_free(info)
}

// The index references the Device_Info_List returned by `get_deviceinfolist`.
device_set :: proc(index: uint) -> bool {
	return CONTEXT_INSTANCE.device_set(index)
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
	context = gfx_default_context()

    error := CONTEXT_INSTANCE.device_check_swapchain_descriptor(descriptor)
	if (gfx_is_debug() && error != .Ok) do log.warn("Force set of the swapchain with error", error)

	CONTEXT_INSTANCE.device_set_swapchain(descriptor)

	return error
}
