package vx_lib_gfx_immediate

import "../../gfx"
import "../../core"
import "../../utils"
import "../../logic"
import "../../logic/objects"
import "core:math"

Context_Descriptor :: struct {
    pass: ^gfx.Pass,
}

@(private)
Context :: struct {
    pass: ^gfx.Pass,

    font_atlas: utils.Texture_Atlas,

    textured_pipeline: gfx.Pipeline,
    color_pipeline: gfx.Pipeline,

    color_batcher: utils.Batcher,
    textured_batcher: utils.Batcher,

    camera: objects.Simple_Camera,
}
@(private)
CONTEXT_INSTANCE: core.Cell(Context)

init :: proc(desc: Context_Descriptor) {
    core.cell_init(&CONTEXT_INSTANCE)

    gfx.pipeline_init(&CONTEXT_INSTANCE.textured_pipeline, gfx.Pipeline_Descriptor {
        cull_enabled = false,
        cull_front_face = .Counter_Clockwise,
        cull_face = .Back,

        depth_enabled = true,
        depth_func = .LEqual,

        blend_enabled = true,
        blend_src_rgb_func = .Src_Alpha,
		blend_dst_rgb_func = .One_Minus_Src_Alpha,
		blend_src_alpha_func = .One,
		blend_dstdst_alphargb_func = .Zero,

		wireframe = false,

        uniform_locations = 3,

        source_path = "res/vx_lib/shaders/immediate_textured",

        layout = TEXTURED_LAYOUT,
    }, desc.pass)

    gfx.pipeline_init(&CONTEXT_INSTANCE.color_pipeline, gfx.Pipeline_Descriptor {
        cull_enabled = false,
        cull_front_face = .Counter_Clockwise,
        cull_face = .Back,

        depth_enabled = true,
        depth_func = .LEqual,

        blend_enabled = true,
        blend_src_rgb_func = .Src_Alpha,
		blend_dst_rgb_func = .One_Minus_Src_Alpha,
		blend_src_alpha_func = .One,
		blend_dstdst_alphargb_func = .Zero,

		wireframe = false,

        uniform_locations = 2,

        source_path = "res/vx_lib/shaders/immediate_colored",

        layout = COLOR_LAYOUT,
    }, desc.pass)

    utils.batcher_init(&CONTEXT_INSTANCE.color_batcher, utils.Batcher_Descriptor {
        primitive = .Triangles,
    })

    utils.batcher_init(&CONTEXT_INSTANCE.textured_batcher, utils.Batcher_Descriptor {
        primitive = .Triangles,
    })

    utils.textureatlas_init_from_file(&CONTEXT_INSTANCE.font_atlas, utils.Texture_Atlas_Descriptor {
		internal_texture_format = .R8G8B8A8,
		warp_s = .Repeat,
		warp_t = .Repeat,
		min_filter = .Nearest,
		mag_filter = .Nearest,
		gen_mipmaps = true,
	}, "res/vx_lib/textures/font_atlas.png", "res/vx_lib/textures/font_atlas.csv")

    logic.camera_init(&CONTEXT_INSTANCE.camera, logic.Orthographic_Camera_Descriptor {
        left   = 0.0,
        right  = (f32)(desc.pass.viewport_size.x),
        top    = (f32)(desc.pass.viewport_size.y),
        bottom = 0.0,
        near   = 0.0001,
        far    = 1000.0,
    })
    CONTEXT_INSTANCE.camera.position = { 0.0, 0.0, 1.0 }
	CONTEXT_INSTANCE.camera.rotation = { math.to_radians_f32(180.0), 0.0, 0.0 }

    CONTEXT_INSTANCE.pass = desc.pass
}

free :: proc() {
    utils.textureatlas_free(&CONTEXT_INSTANCE.font_atlas)

    gfx.pipeline_free(&CONTEXT_INSTANCE.textured_pipeline)
    gfx.pipeline_free(&CONTEXT_INSTANCE.color_pipeline)

    utils.batcher_free(&CONTEXT_INSTANCE.color_batcher)
    utils.batcher_free(&CONTEXT_INSTANCE.textured_batcher)
}
