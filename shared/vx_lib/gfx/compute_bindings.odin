package vx_lib_gfx

import "core:slice"

Compute_Bindings_Raw_Element :: struct {
    size: uint,
    data: rawptr,
}

Compute_Bindings_Buffer_Element :: struct {
    buffer: Compute_Buffer,
}

Compute_Bindings_U32_Element :: struct {
    value: u32,
}

Compute_Bindings_I32_Element :: struct {
    value: i32,
}

Compute_Bindings_F32_Element :: struct {
    value: f32,
}

Compute_Bindings_2F32_Element :: struct {
    value: [2]f32,
}


Compute_Bindings_Element :: union #no_nil {
    Compute_Bindings_Raw_Element,
    Compute_Bindings_Buffer_Element,
    Compute_Bindings_U32_Element,
    Compute_Bindings_I32_Element,
    Compute_Bindings_F32_Element,
    Compute_Bindings_2F32_Element,
}

Compute_Bindings_Impl :: struct {
    elements: []Compute_Bindings_Element,
}
Compute_Bindings :: ^Compute_Bindings_Impl

computebindings_new :: proc(layout: []Compute_Bindings_Element) -> Compute_Bindings {
    if len(layout) > 16 do panic("Only 16 arguments allowed!")

    bindings := new(Compute_Bindings_Impl, OPENCL_CONTEXT.cl_allocator)
    bindings.elements = slice.clone(layout, OPENCL_CONTEXT.cl_allocator)

    return bindings
}

computebindings_set_element :: proc(bindings: Compute_Bindings, index: uint, element: Compute_Bindings_Element) {
    when ODIN_DEBUG do if index >= len(bindings.elements) do panic("Out of bound set.")

    bindings.elements[index] = element
}

computebindings_free :: proc(bindings: Compute_Bindings) {
    delete(bindings.elements)

    free(bindings, OPENCL_CONTEXT.cl_allocator)
}