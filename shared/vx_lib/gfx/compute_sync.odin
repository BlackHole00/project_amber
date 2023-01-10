package vx_lib_gfx

import cl "shared:OpenCL"

@(private)
cleventsync_new :: proc(event: cl.event, info: Sync_Info_Type) -> Sync {
    return sync_new(Sync_Descriptor {
        info = .Compute_Buffer_Upload,
        data = event,
        is_done_proc = proc(sync: Sync) -> bool {
            status: i32 = ---
            cl.GetEventInfo((cl.event)(sync.data), cl.EVENT_COMMAND_EXECUTION_STATUS, size_of(i32), &status, nil)
        
            return status == cl.COMPLETE
        },
        wait_proc = proc(sync: Sync) {
            event := (cl.event)(sync.data)
            cl.WaitForEvents(1, &event)
        },
        free_proc = proc(sync: Sync) {
            free(sync, OPENCL_CONTEXT.cl_allocator)
        },
    }, OPENCL_CONTEXT.cl_allocator)
}

cldispatchsync_new :: proc(dispatch_event: cl.event, bindings: Compute_Bindings) -> Sync {
    Cl_Dispatch_Sync_Data :: struct {
        event: cl.event,
        bindings: Compute_Bindings,
    }

    data := new(Cl_Dispatch_Sync_Data, OPENCL_CONTEXT.cl_allocator)
    data.event = dispatch_event
    data.bindings = bindings

    return sync_new(Sync_Descriptor {
        info = .Compute_Dispatch,
        data = data,
        is_done_proc = proc(sync: Sync) -> bool {
            data := (^Cl_Dispatch_Sync_Data)(sync.data)

            status: i32 = ---
            cl.GetEventInfo(data.event, cl.EVENT_COMMAND_EXECUTION_STATUS, size_of(i32), &status, nil)
        
            return status == cl.COMPLETE
        },
        wait_proc = proc(sync: Sync) {
            data := (^Cl_Dispatch_Sync_Data)(sync.data)
            cl.WaitForEvents(1, &data.event)
        },
        free_proc = proc(sync: Sync) {
            data := (^Cl_Dispatch_Sync_Data)(sync.data)

            for element in data.bindings.elements {
                #partial switch v in element {
                    case Compute_Bindings_Buffer_Element: computebuffer_glrelease(v.buffer)
                }
            }

            free(sync.data, OPENCL_CONTEXT.cl_allocator)
            free(sync, OPENCL_CONTEXT.cl_allocator)
        },
    }, OPENCL_CONTEXT.cl_allocator)
}