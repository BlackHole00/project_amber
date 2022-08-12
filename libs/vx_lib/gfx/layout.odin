package vx_lib_gfx

import gl "vendor:OpenGL"
import "core:log"

Layout_Resolution_Element :: struct {
    index: u32,
    size:  i32,
    gl_type: u32,
    normalized: bool,
    stride: i32,
    offset: uintptr,
    buffer_idx: uint,
    divisor: u32,
}

Layout_Element :: struct {
    gl_type: u32,
    count: uint,
    normalized: bool,
    buffer_idx: uint,
    divisor: uint,
}

Layout_Descriptor :: struct {
    elements: []Layout_Element,
}

Layout :: struct {
    layout_handle: u32,
    layout_resolution: []Layout_Resolution_Element,
}

layout_init :: proc(layout: ^Layout, desc: Layout_Descriptor) {
    gl.CreateVertexArrays(1, &layout.layout_handle)

    layout_resolve(layout, desc.elements)
}

layout_bind :: proc(layout: Layout) {
    gl.BindVertexArray(layout.layout_handle)
}

layout_free :: proc(layout: ^Layout) {
    gl.DeleteVertexArrays(1, &layout.layout_handle)
    delete(layout.layout_resolution)

    layout.layout_handle = INVALID_HANDLE
}

layout_apply_without_index_buffer :: proc(layout: Layout, vertex_buffers: []Buffer) {
    layout_bind(layout)

    for resolution in layout.layout_resolution {
        buffer_bind(vertex_buffers[resolution.buffer_idx])
        log.info(resolution.index, resolution.size, resolution.gl_type, resolution.normalized, resolution.stride, resolution.offset)
        gl.VertexAttribPointer(resolution.index, resolution.size, resolution.gl_type, resolution.normalized, resolution.stride, resolution.offset)
        gl.EnableVertexAttribArray(resolution.index)
        gl.VertexAttribDivisor(resolution.index, resolution.divisor)
    }
}

layout_apply_with_index_buffer :: proc(layout: Layout, vertex_buffers: []Buffer, index_buffer: Buffer) {
    layout_apply_without_index_buffer(layout, vertex_buffers)
    buffer_bind(index_buffer)
}

layout_apply :: proc { layout_apply_without_index_buffer, layout_apply_with_index_buffer }

@(private)
layout_resolve :: proc(layout: ^Layout, elements: []Layout_Element) {
    layout_bind(layout^)

    layout.layout_resolution = make([]Layout_Resolution_Element, len(elements))

    buffer_count := layout_find_buffer_count(elements)
    
    strides := make([]uint, buffer_count)
    defer delete(strides)

    offsets := make([]uint, buffer_count)
    defer delete(offsets)

    for elem in elements do strides[elem.buffer_idx] += size_of_gl_type(elem.gl_type) * elem.count
    for stride, i in strides do offsets[i] = stride

    for i := len(elements) - 1; i >= 0; i -= 1 {
        layout_index := i

        offsets[elements[i].buffer_idx] -= size_of_gl_type(elements[i].gl_type) * elements[i].count

        log.info((u32)(layout_index), (i32)(elements[i].count), elements[i].gl_type, elements[i].normalized, (i32)(strides[elements[i].buffer_idx]), (uintptr)(offsets[elements[i].buffer_idx]))
        layout.layout_resolution[i] = Layout_Resolution_Element {
            index = (u32)(layout_index),
            size = (i32)(elements[i].count),
            gl_type = elements[i].gl_type,
            normalized = elements[i].normalized,
            stride = (i32)(strides[elements[i].buffer_idx]),
            offset = (uintptr)(offsets[elements[i].buffer_idx]),
            buffer_idx = elements[i].buffer_idx,
            divisor = (u32)(elements[i].divisor),
        }
    }
}

@(private)
layout_find_buffer_count :: proc(elements: []Layout_Element) -> (count: uint = 0) {
    for elem in elements {
        if elem.buffer_idx > count do count = elem.buffer_idx
    }
    count += 1

    return
}
