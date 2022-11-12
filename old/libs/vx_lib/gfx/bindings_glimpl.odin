package vx_lib_gfx

@(private)
_glimpl_bindings_apply :: proc(pipeline: ^Pipeline, bindings: ^Bindings) {
    if bindings.index_buffer == nil do _glimpl_pipeline_layout_apply_without_index_buffer(pipeline^, bindings.vertex_buffers[:bindings.vertex_count])
    else do _glimpl_pipeline_layout_apply_with_index_buffer(pipeline^, bindings.vertex_buffers[:bindings.vertex_count], bindings.index_buffer.(Buffer))

    for i in 0..<bindings.texture_count {
        _glimpl_texture_apply(bindings.textures[i].texture, (u32)(i), pipeline, bindings.textures[i].uniform_location)
        _glimpl_texture_full_bind(bindings.textures[i].texture, (u32)(i))
    }
}