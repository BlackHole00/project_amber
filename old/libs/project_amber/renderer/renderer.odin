package project_amber_renderer

import "vx_lib:core"
import "vx_lib:gfx"
import "vx_lib:logic"
import "vx_lib:logic/objects"
import "vx_lib:utils"
import "vx_lib:platform"

BLOCK_TEXTURE_ATLAS_LOCATION :: 3

Renderer :: struct {
    block_texture_atlas: utils.Texture_Atlas,

    full_block_solid_pipeline: gfx.Pipeline,

    skybox_pipeline: gfx.Pipeline,
	skybox: objects.Skybox,
	skybox_bindings: gfx.Bindings,

    pass: gfx.Pass,
}
RENDERER_INSTANCE: core.Cell(Renderer)

renderer_init :: proc() {
    core.cell_init(&RENDERER_INSTANCE)

    window_size := platform.windowhelper_get_window_size()

    // TODO: make textureatlas dynamic and register textures at runtime.
    utils.textureatlas_init(&RENDERER_INSTANCE.block_texture_atlas, utils.Texture_Atlas_Descriptor {
        internal_texture_format = .R8G8B8,
        warp_s = .Clamp_To_Border,
        warp_t = .Clamp_To_Border,
        min_filter = .Nearest,
        mag_filter = .Nearest,
        gen_mipmaps = true,
    }, "res/project_amber/textures/block_atlas.png", "res/project_amber/textures/block_atlas.csv")

    gfx.pass_init(&RENDERER_INSTANCE.pass, gfx.Pass_Descriptor {
        clearing_color = { 0, 0, 0, 0 },
        clear_color = true,
        clear_depth = true,

        viewport_size = window_size,
    })

    gfx.pipeline_init(&RENDERER_INSTANCE.full_block_solid_pipeline, gfx.Pipeline_Descriptor {
        cull_enabled = true,
        cull_face = .Back,
        cull_front_face = .Counter_Clockwise,

        depth_enabled = true,
        depth_func = .LEqual,

        blend_enabled = false,

        wireframe = false,

        layout = WORLD_VERTEX_LAYOUT,

        uniform_locations = 4,

        source_path = "res/project_amber/shaders/full_solid_block",
    }, &RENDERER_INSTANCE.pass)

	gfx.pipeline_init(&RENDERER_INSTANCE.skybox_pipeline, gfx.Pipeline_Descriptor { 
		cull_enabled = false,
		depth_enabled = false,
		blend_enabled = false,

		wireframe = false,

        uniform_locations = 3,

        layout = SKYBOX_LAYOUT,

        source_path = "res/project_amber/shaders/skybox",
	}, &RENDERER_INSTANCE.pass)

	logic.skybox_init(&RENDERER_INSTANCE.skybox.mesh, &RENDERER_INSTANCE.skybox.texture, 
        "res/project_amber/textures/skybox/right.bmp",
        "res/project_amber/textures/skybox/left.bmp",
        "res/project_amber/textures/skybox/top.bmp",
        "res/project_amber/textures/skybox/bottom.bmp",
        "res/project_amber/textures/skybox/front.bmp",
        "res/project_amber/textures/skybox/back.bmp",
    )
}

renderer_free :: proc() {
    utils.textureatlas_free(&RENDERER_INSTANCE.block_texture_atlas)
    gfx.pipeline_free(&RENDERER_INSTANCE.full_block_solid_pipeline)
    gfx.pipeline_free(&RENDERER_INSTANCE.skybox_pipeline)
    gfx.pass_free(&RENDERER_INSTANCE.pass)
    logic.skybox_free(&RENDERER_INSTANCE.skybox.mesh, &RENDERER_INSTANCE.skybox.texture)
}

renderer_update_camera :: proc(camera: logic.Camera_Component, position: logic.Position_Component, rotation: logic.Rotation_Component) {
    logic.camera_apply(camera, position, rotation, &RENDERER_INSTANCE.full_block_solid_pipeline)
    logic.camera_apply(camera, position, rotation, &RENDERER_INSTANCE.skybox_pipeline, gfx.SKYBOX_VIEW_UNIFORM_LOCATION, gfx.SKYBOX_PROJ_UNIFORM_LOCATION)
}

renderer_resize :: proc(size: [2]uint) {
    gfx.pass_resize(&RENDERER_INSTANCE.pass, size)
}

renderer_draw_skybox :: proc() {
	logic.skybox_draw(&RENDERER_INSTANCE.skybox_pipeline, RENDERER_INSTANCE.skybox.mesh, RENDERER_INSTANCE.skybox.texture)
}

renderer_begin_drawing :: proc() {
	gfx.pass_begin(&RENDERER_INSTANCE.pass)
}

renderer_end_drawing :: proc() {
    gfx.pass_end(&RENDERER_INSTANCE.pass)
}

renderer_get_pass :: proc() -> ^gfx.Pass {
    return &RENDERER_INSTANCE.pass
}
