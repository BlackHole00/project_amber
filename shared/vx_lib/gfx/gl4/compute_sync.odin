package vx_lib_gfx_gl4

import cl "shared:OpenCL"
import "shared:vx_lib/gfx"

@(private)
cleventsync_new :: proc(event: cl.event, info: gfx.Sync_Info_Type) -> gfx.Sync {
    return gfx.sync_new(gfx.Sync_Descriptor {
        info = .Compute_Buffer_Upload,
        data = event,
        is_done_proc = proc(sync: gfx.Sync) -> bool {
            status: i32 = ---
            cl.GetEventInfo((cl.event)(sync.data), cl.EVENT_COMMAND_EXECUTION_STATUS, size_of(i32), &status, nil)

            return status == cl.COMPLETE
        },
        wait_proc = proc(sync: gfx.Sync) {
            event := (cl.event)(sync.data)
            cl.WaitForEvents(1, &event)
        },
        free_proc = proc(sync: gfx.Sync) {
            free(sync, CONTEXT.gl_allocator)
        },
    }, CONTEXT.gl_allocator)
}

cldispatchsync_new :: proc(dispatch_event: cl.event, bindings: gl4Compute_Bindings) -> gfx.Sync {
    Cl_Dispatch_Sync_Data :: struct {
        event: cl.event,
        bindings: gl4Compute_Bindings,
    }

    data := new(Cl_Dispatch_Sync_Data, CONTEXT.gl_allocator)
    data.event = dispatch_event
    data.bindings = bindings

    return gfx.sync_new(gfx.Sync_Descriptor {
        info = .Compute_Dispatch,
        data = data,
        is_done_proc = proc(sync: gfx.Sync) -> bool {
            data := (^Cl_Dispatch_Sync_Data)(sync.data)

            status: i32 = ---
            cl.GetEventInfo(data.event, cl.EVENT_COMMAND_EXECUTION_STATUS, size_of(i32), &status, nil)
        
            return status == cl.COMPLETE
        },
        wait_proc = proc(sync: gfx.Sync) {
            data := (^Cl_Dispatch_Sync_Data)(sync.data)
            cl.WaitForEvents(1, &data.event)
        },
        free_proc = proc(sync: gfx.Sync) {
            data := (^Cl_Dispatch_Sync_Data)(sync.data)

            for element in data.bindings.elements {
                #partial switch v in element {
                    case gfx.Compute_Bindings_Buffer_Element: computebuffer_glrelease((gl4Compute_Buffer)(v.buffer))
                }
            }

            free(sync.data, CONTEXT.gl_allocator)
            free(sync, CONTEXT.gl_allocator)
        },
    }, CONTEXT.gl_allocator)
}