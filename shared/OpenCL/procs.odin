package OpenCL

import "core:c"

when ODIN_OS == .Windows { 
    when ODIN_ARCH == .amd64 do foreign import OpenCL "OpenCL64.lib"
    when ODIN_ARCH == .i386 do foreign import OpenCL "OpenCL32.lib"
}
else when ODIN_OS == .Darwin do foreign import OpenCL "system:OpenCL.framework"
else do foreign import OpenCL "system:OpenCL"

@(default_calling_convention="c", link_prefix="cl")
foreign OpenCL {
    GetDeviceIDs        :: proc(plaform: platform_id, device_type: device_type, num_entries: u32, devices: [^]device_id, num_devices: ^u32) -> i32 ---
    GetDeviceInfo       :: proc(device: device_id, param_name: device_info, param_value_size: c.size_t, param_value: rawptr, param_value_size_ret: ^c.size_t) -> i32 ---
    CreateContext       :: proc(properties: ^context_properties, 
        num_devices: u32, 
        devices: [^]device_id, 
        pfn_notify: proc "c" (cstring, rawptr, c.size_t, rawptr),
        user_data: rawptr,
        errcore_ret: ^i32,
    ) -> cl_context ---
    CreateCommandQueue  :: proc(cl_context: cl_context, device: device_id, properties: command_queue_properties, errcode_ret: ^i32) -> command_queue ---
    GetPlatformIDs      :: proc(num_entries: u32, platforms: [^]platform_id, num_platforms: [^]u32) -> i32 ---
    
    CreateProgramWithSource :: proc(cl_context: cl_context, count: u32, strings: [^]cstring, lenghts: [^]c.size_t, errcore_ret: ^i32) -> program ---
    BuildProgram        :: proc(
        program: program, 
        num_devices: u32, 
        device_list: [^]device_id, 
        options: cstring, 
        pfn_notify: proc "c" (program: program, user_data: rawptr),
        user_data: rawptr,
    ) -> i32 ---
    CreateKernel        :: proc(program: program, kernel_name: cstring, errcode_ret: ^i32) -> kernel ---
    CreateBuffer        :: proc(cl_context: cl_context, flags: mem_flags, size: c.size_t, host_ptr: rawptr, errcode_ret: ^i32) -> mem ---
    EnqueueWriteBuffer  :: proc(
        command_queue: command_queue,
        buffer: mem,
        blocking_write: bool,
        offset: c.size_t,
        size: c.size_t,
        ptr: rawptr,
        num_events_in_wait_list: u32,
        event_wait_list: [^]event,
        event: ^event,
    ) -> i32 ---
    EnqueueReadBuffer   :: proc(
        command_queue: command_queue,
        buffer: mem,
        blocking_read: bool,
        offset: c.size_t,
        size: c.size_t,
        ptr: rawptr,
        num_events_in_wait_list: u32,
        event_wait_list: [^]event,
        event: ^event,
    ) -> i32 ---
    SetKernelArg        :: proc(kernel: kernel, arg_index: u32, arg_size: c.size_t, arg_value: rawptr) -> i32 ---
    GetKernelWorkGroupInfo  :: proc(
        kernel: kernel, 
        device: device_id, 
        param_name: kernel_work_group_info, 
        param_value_size: c.size_t,
        param_value: rawptr,
        param_value_size_ret: ^c.size_t,
    ) -> i32 ---
    EnqueueNDRangeKernel    :: proc(
        command_queue: command_queue,
        kernel: kernel,
        work_dim: u32,
        global_work_offset: [^]c.size_t,
        global_work_size: [^]c.size_t,
        local_work_size: [^]c.size_t,
        num_events_in_wait_list: u32,
        event_wait_list: [^]event,
        event: ^event,
    ) -> i32 ---
    Flush               :: proc(command_queue: command_queue) -> i32 ---
    WaitForEvents       :: proc(num_events: u32, event_list: [^]event) -> i32 ---

    ReleaseMemObject    :: proc(memobj: mem) -> i32 ---
    ReleaseProgram      :: proc(program: program) -> i32 ---
    ReleaseKernel       :: proc(kernel: kernel) -> i32 ---
    ReleaseCommandQueue :: proc(command_queue: command_queue) -> i32 ---
    ReleaseContext      :: proc(cl_context: cl_context) -> i32 ---

    EnqueueAcquireGLObjects :: proc(
        command_queue: command_queue,
        num_objects: u32,
        mem_objects: [^]mem,
        num_events_in_wait_list: u32,
        event_wait_list: [^]event,
        event: ^event,
    ) -> i32 ---
    EnqueueReleaseGLObjects :: proc(
        command_queue: command_queue,
        num_objects: u32,
        mem_objects: [^]mem,
        num_events_in_wait_list: u32,
        event_wait_list: [^]event,
        event: ^event,
    ) -> i32 ---
    CreateFromGLTexture :: proc(
        cl_context: cl_context,
        flags: mem_flags,
        target: u32,
        miplevel: i32,
        texture: u32,
        errcode_ret: ^i32,
    ) -> mem ---
    CreateFromGlBuffer :: proc(
        cl_context: cl_context,
        flags: mem_flags,
        bufobj: u32,
        errcode_ret: ^i32,
    ) -> mem ---
    GetEventInfo :: proc(
        event: event,
        param_name: event_info,
        param_value_size: c.size_t,
        param_value: rawptr,
        param_value_size_ret: ^c.size_t,
    ) -> i32 ---
}