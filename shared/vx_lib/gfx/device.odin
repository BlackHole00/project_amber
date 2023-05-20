package vx_lib_gfx

import "core:log"

Device_Type :: enum {
    Software,
    Power_Efficient,
    Performance,
	Unknown,
}

Device_Vendor :: enum {
	Nvidia,
	Amd,
	Intel,
	Other,
	Unknown,
}

Device_Info :: struct {
	device_description: string,
	device_vendor: Device_Vendor,
	device_type: Device_Type,

	// limits and other information to be added in the future
}

Device_Info_List :: []Device_Info

get_deviceinfo_of_idx :: proc(index: uint) -> Maybe(Device_Info) {
	context = gfx_default_context()

	if index >= get_device_count() {
		log.warn("The user requested information about a device that doesn't exist.")
		return nil
	}

	return CONTEXT_INSTANCE.get_deviceinfo_of_idx(index)
}

get_device_count :: proc() -> uint {
	return CONTEXT_INSTANCE.get_device_count()
}

get_deviceinfolist :: proc() -> Device_Info_List {
	context = gfx_default_context()

	list := make(Device_Info_List, get_device_count())
	for info, i in &list {
		info = get_deviceinfo_of_idx((uint)(i)).?
	}

	return list
}

// Return the device info. Return nil if the device has not been chosen yet.
device_get_info :: proc() -> Maybe(Device_Info) {
	if CONTEXT_INSTANCE.selected_device_index == nil {
		log.warn("Requested device info while a device has not been set.")

		return nil
	}

	return get_deviceinfo_of_idx(CONTEXT_INSTANCE.selected_device_index.?)
}

deviceinfolist_free :: proc(list: Device_Info_List) {
	for info in list {
		deviceinfo_free(info)
	}

	delete(list)
}

deviceinfo_free :: proc(info: Device_Info) {
    CONTEXT_INSTANCE.deviceinfo_free(info)
}

// The index references the Device_Info_List returned by `get_deviceinfolist`.
device_set :: proc(index: uint) -> bool {
	context = gfx_default_context()

	if index >= get_device_count() {
		log.warn("Trying to set a device that is non existent (out-of-bounds).")
		return false
	}

	result := CONTEXT_INSTANCE.device_set(index)
	if result {
		CONTEXT_INSTANCE.selected_device_index = index
	}

	return result
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
