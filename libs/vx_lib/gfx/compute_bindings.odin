package vx_lib_gfx

import "core:mem"

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

Compute_Bindings_Element :: union #no_nil {
    Compute_Bindings_Raw_Element,
    Compute_Bindings_Buffer_Element,
    Compute_Bindings_U32_Element,
    Compute_Bindings_I32_Element,
}

Compute_Bindings :: struct {
    elements: [16]Compute_Bindings_Element,
    used_elements: u8,
}

computebindings_init :: proc(bindings: ^Compute_Bindings, layout: []Compute_Bindings_Element) {
    if len(layout) > 16 do panic("Only 16 arguments allowed!")

    mem.copy(&bindings.elements[0], &layout[0], size_of(Compute_Bindings_Element) * len(layout))

    bindings.used_elements = (u8)(len(layout))
}