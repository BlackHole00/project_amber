package vx_lib_gfx_immediate

import "../../gfx"
import "../../core"
import "../../utils"
import "core:os"
import gl "vendor:OpenGL"

Context_Descriptor :: struct {
    target_framebuffer: Maybe(gfx.Framebuffer),
    viewport_size: [2]uint,
}

@(private)
Context :: struct {
    font_atlas: utils.Texture_Atlas,

    textured_pipeline: gfx.Pipeline,
    color_pipeline: gfx.Pipeline,

    color_batcher: utils.Batcher,
    textured_batcher: utils.Batcher,
}
@(private)
CONTEXT_INSTANCE: core.Cell(Context)

context_init :: proc(desc: Context_Descriptor) {
    core.cell_init(&CONTEXT_INSTANCE)

    immediate_textured_vertex_src, ok := os.read_entire_file("res/vx_lib/shaders/immediate_textured.vs")
	if !ok do panic("Could not open vertex shader file")
    defer delete(immediate_textured_vertex_src)

	immediate_textured_fragment_src, ok2 := os.read_entire_file("res/vx_lib/shaders/immediate_textured.fs")
	if !ok2 do panic("Could not open fragment shader file")
    defer delete(immediate_textured_fragment_src)

    immediate_colored_vertex_src, ok3 := os.read_entire_file("res/vx_lib/shaders/immediate_colored.vs")
	if !ok3 do panic("Could not open vertex shader file")
    defer delete(immediate_colored_vertex_src)

	immediate_colored_fragment_src, ok4 := os.read_entire_file("res/vx_lib/shaders/immediate_colored.fs")
	if !ok4 do panic("Could not open fragment shader file")
    defer delete(immediate_colored_fragment_src)

    gfx.pipeline_init(&CONTEXT_INSTANCE.textured_pipeline, gfx.Pipeline_Descriptor {
        cull_enabled = false,
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

        vertex_source = (string)(immediate_textured_vertex_src),
        fragment_source = (string)(immediate_textured_fragment_src),

        layout = TEXTURED_LAYOUT,
    }, desc.target_framebuffer)

    gfx.pipeline_init(&CONTEXT_INSTANCE.color_pipeline, gfx.Pipeline_Descriptor {
        cull_enabled = false,
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

        vertex_source = (string)(immediate_colored_vertex_src),
        fragment_source = (string)(immediate_colored_fragment_src),

        layout = COLOR_LAYOUT,
    }, desc.target_framebuffer)

    utils.batcher_init(&CONTEXT_INSTANCE.color_batcher, utils.Batcher_Descriptor {
        primitive = gl.TRIANGLES,
    })

    utils.batcher_init(&CONTEXT_INSTANCE.textured_batcher, utils.Batcher_Descriptor {
        primitive = gl.TRIANGLES,
    })

    utils.textureatlas_init_from_file(&CONTEXT_INSTANCE.font_atlas, utils.Texture_Atlas_Descriptor {
		internal_texture_format = gl.RGBA8,
		warp_s = gl.REPEAT,
		warp_t = gl.REPEAT,
		min_filter = gl.NEAREST,
		mag_filter = gl.NEAREST,
		gen_mipmaps = true,
	}, "res/textures/font_atlas.png", "res/textures/font_atlas.csv")
}

context_free :: proc() {
    utils.textureatlas_free(&CONTEXT_INSTANCE.font_atlas)

    gfx.pipeline_free(&CONTEXT_INSTANCE.textured_pipeline)
    gfx.pipeline_free(&CONTEXT_INSTANCE.color_pipeline)

    utils.batcher_free(&CONTEXT_INSTANCE.color_batcher)
    utils.batcher_free(&CONTEXT_INSTANCE.textured_batcher)
}
