package vx_lib_gfx_gl3

import "core:slice"
import "shared:vx_lib/gfx"

Compute_Bindings_Impl :: struct {
    elements: []gfx.Compute_Bindings_Element,
}
Gl3Compute_Bindings :: ^Compute_Bindings_Impl

computebindings_new :: proc(layout: []gfx.Compute_Bindings_Element) -> Gl3Compute_Bindings {
    bindings := new(Compute_Bindings_Impl, CONTEXT.gl_allocator)
    bindings.elements = slice.clone(layout, CONTEXT.gl_allocator)

    return bindings
}

computebindings_set_element :: proc(bindings: Gl3Compute_Bindings, index: uint, element: gfx.Compute_Bindings_Element) {
    bindings.elements[index] = element
}

computebindings_free :: proc(bindings: Gl3Compute_Bindings) {
    delete(bindings.elements)

    free(bindings, CONTEXT.gl_allocator)
}