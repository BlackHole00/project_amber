package vx_lib_gfx_gl4

import "core:slice"
import "shared:vx_lib/gfx"

Compute_Bindings_Impl :: struct {
    elements: []gfx.Compute_Bindings_Element,
}
gl4Compute_Bindings :: ^Compute_Bindings_Impl

computebindings_new :: proc(layout: []gfx.Compute_Bindings_Element) -> gl4Compute_Bindings {
    if len(layout) > 16 do panic("Only 16 arguments allowed!")

    bindings := new(Compute_Bindings_Impl, CONTEXT.gl_allocator)
    bindings.elements = slice.clone(layout, CONTEXT.gl_allocator)

    return bindings
}

computebindings_set_element :: proc(bindings: gl4Compute_Bindings, index: uint, element: gfx.Compute_Bindings_Element) {
    when ODIN_DEBUG do if index >= len(bindings.elements) do panic("Out of bound set.")

    bindings.elements[index] = element
}

computebindings_free :: proc(bindings: gl4Compute_Bindings) {
    delete(bindings.elements)

    free(bindings, CONTEXT.gl_allocator)
}