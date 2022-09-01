package vx_lib_gfx

when ODIN_OS == .Darwin {

import MTL "vendor:darwin/Metal"
import NS "vendor:darwin/Foundation"
import "core:log"

@(private)
_metalimpl_bindings_apply :: proc(bindings: ^Bindings, encoder: ^MTL.RenderCommandEncoder) {
    for i in 0..<bindings.vertex_count {
        encoder->setVertexBuffer(_metalimpl_buffer_get_mtl_buffer(bindings.vertex_buffers[i]), 0, (NS.UInteger)(i))
    }

    for i in 0..<bindings.texture_count {
        log.warn("Textures are not yet supported!")
    }
}

}