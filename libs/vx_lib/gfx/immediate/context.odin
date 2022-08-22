package vx_lib_gfx_immediate

import "../../gfx"
import "../../core"
import "../../utils"
import gl "vendor:OpenGL"

Context_Descriptor :: struct {
    target_framebuffer: Maybe(gfx.Framebuffer),
    viewport_size: [2]uint,
}

Context :: struct {
    textured_pipeline: gfx.Pipeline,
    color_pipeline: gfx.Pipeline,

    batcher: utils.Batcher,
}
CONTEXT_INSTANCE: core.Cell(Context)

context_init :: proc(desc: Context_Descriptor) {
    core.cell_init(&CONTEXT_INSTANCE)

    gfx.pipeline_init(&CONTEXT_INSTANCE.textured_pipeline, gfx.Pipeline_Descriptor {
        cull_enabled = true,
        cull_front_face = gl.CCW,
        cull_face = gl.BACK,

        depth_enabled = true,
        depth_func = gl.LEQUAL,

        blend_enabled = true,

        blend_src_rgb_func = gl.SRC_ALPHA,
		blend_dst_rgb_func = gl.ONE_MINUS_SRC_ALPHA,
		blend_src_alpha_func = gl.ONE,
		blend_dstdst_alphargb_func = gl.ZERO,

		wireframe = false,

		viewport_size = desc.viewport_size,

		clear_color = { 0.0, 0.0, 0.0, 0.0 },
    }, desc.target_framebuffer)

    gfx.pipeline_init(&CONTEXT_INSTANCE.color_pipeline, gfx.Pipeline_Descriptor {
        cull_enabled = true,
        cull_front_face = gl.CCW,
        cull_face = gl.BACK,

        depth_enabled = true,
        depth_func = gl.LEQUAL,

        blend_enabled = true,

        blend_src_rgb_func = gl.SRC_ALPHA,
		blend_dst_rgb_func = gl.ONE_MINUS_SRC_ALPHA,
		blend_src_alpha_func = gl.ONE,
		blend_dstdst_alphargb_func = gl.ZERO,

		wireframe = false,

		viewport_size = desc.viewport_size,

		clear_color = { 0.0, 0.0, 0.0, 0.0 },
    }, desc.target_framebuffer)
}
