package vx_lib_gfx_immediate

import "../../gfx"
import "../../core"
import "../../utils"
import "../../logic"
import "../../logic/objects"
import "core:math"

Context_Descriptor :: struct {
    target_framebuffer: Maybe(gfx.Framebuffer),
    viewport_size: [2]uint,

    clear_depth_buffer: bool,
    clear_color: bool,
}

@(private)
Context :: struct {
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

		viewport_size = desc.viewport_size,

        source_path = "res/vx_lib/shaders/immediate_textured",

		clearing_color = { 0.0, 0.0, 0.0, 0.0 },
        clear_depth = desc.clear_depth_buffer,
        clear_color = desc.clear_color,

        layout = TEXTURED_LAYOUT,
    }, desc.target_framebuffer)

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

		viewport_size = desc.viewport_size,

		clearing_color = { 0.0, 0.0, 0.0, 0.0 },
        clear_depth = desc.clear_depth_buffer,
        clear_color = desc.clear_color,

        source_path = "res/vx_lib/shaders/immediate_colored",

        layout = COLOR_LAYOUT,
    }, desc.target_framebuffer)

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
        right  = (f32)(desc.viewport_size.x),
        top    = (f32)(desc.viewport_size.y),
        bottom = 0.0,
        near   = 0.0001,
        far    = 1000.0,
    })
    CONTEXT_INSTANCE.camera.position = { 0.0, 0.0, 1.0 }
	CONTEXT_INSTANCE.camera.rotation = { math.to_radians_f32(180.0), 0.0, 0.0 }
}

free :: proc() {
    utils.textureatlas_free(&CONTEXT_INSTANCE.font_atlas)

    gfx.pipeline_free(&CONTEXT_INSTANCE.textured_pipeline)
    gfx.pipeline_free(&CONTEXT_INSTANCE.color_pipeline)

    utils.batcher_free(&CONTEXT_INSTANCE.color_batcher)
    utils.batcher_free(&CONTEXT_INSTANCE.textured_batcher)
}
