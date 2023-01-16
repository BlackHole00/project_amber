package vx_lib_gfx

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

Compute_Bindings :: distinct rawptr

computebindings_new :: proc(layout: []Compute_Bindings_Element) -> Compute_Bindings {
    return GFXPROCS_INSTANCE.computebindings_new(layout)
}

computebindings_set_element :: proc(bindings: Compute_Bindings, index: uint, element: Compute_Bindings_Element) {
    GFXPROCS_INSTANCE.computebindings_set_element(bindings, index, element)
}

computebindings_free :: proc(bindings: Compute_Bindings) {
    GFXPROCS_INSTANCE.computebindings_free(bindings)
}