package project_amber_renderer

import "core:os"
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

    full_solid_block_vertex_src, ok := os.read_entire_file("res/project_amber/shaders/full_solid_block.vs")
	if !ok do panic("Could not open vertex shader file")
    defer delete(full_solid_block_vertex_src)

	full_solid_block_fragment_src, ok2 := os.read_entire_file("res/project_amber/shaders/full_solid_block.fs")
	if !ok2 do panic("Could not open fragment shader file")
    defer delete(full_solid_block_fragment_src)

    gfx.pipeline_init(&RENDERER_INSTANCE.full_block_solid_pipeline, gfx.Pipeline_Descriptor {
        cull_enabled = true,
        cull_face = .Back,
        cull_front_face = .Counter_Clockwise,

        depth_enabled = true,
        depth_func = .LEqual,

        blend_enabled = false,

        wireframe = false,

        viewport_size = window_size,

        clear_color = true,
        clear_depth = true,

        layout = WORLD_VERTEX_LAYOUT,

        vertex_source = (string)(full_solid_block_vertex_src),
        fragment_source = (string)(full_solid_block_fragment_src),
    })

    skybox_vertex_src, ok3 := os.read_entire_file("res/project_amber/shaders/skybox.vs")
	if !ok3 do panic("Could not open vertex shader file")
	defer delete(skybox_vertex_src)

	skybox_fragment_src, ok4 := os.read_entire_file("res/project_amber/shaders/skybox.fs")
	if !ok4 do panic("Could not open fragment shader file")
	defer delete(skybox_fragment_src)

	gfx.pipeline_init(&RENDERER_INSTANCE.skybox_pipeline, gfx.Pipeline_Descriptor { 
		cull_enabled = false,
		depth_enabled = false,
		blend_enabled = false,

		wireframe = false,

		viewport_size = window_size,

		clear_color = false,
		clear_depth = false,

        layout = SKYBOX_LAYOUT,

        vertex_source = (string)(skybox_vertex_src),
		fragment_source = (string)(skybox_fragment_src),
	})

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
    logic.skybox_free(&RENDERER_INSTANCE.skybox.mesh, &RENDERER_INSTANCE.skybox.texture)
}

renderer_update_camera :: proc(camera: logic.Camera_Component, position: logic.Position_Component, rotation: logic.Rotation_Component) {
    logic.camera_apply(camera, position, rotation, &RENDERER_INSTANCE.full_block_solid_pipeline)
    logic.camera_apply(camera, position, rotation, &RENDERER_INSTANCE.skybox_pipeline, gfx.SKYBOX_VIEW_UNIFORM_LOCATION, gfx.SKYBOX_PROJ_UNIFORM_LOCATION)
}

renderer_resize :: proc(size: [2]uint) {
    gfx.pipeline_resize(&RENDERER_INSTANCE.full_block_solid_pipeline, size)
    gfx.pipeline_resize(&RENDERER_INSTANCE.skybox_pipeline, size)
}

renderer_draw_skybox :: proc() {
	logic.skybox_draw(&RENDERER_INSTANCE.skybox_pipeline, RENDERER_INSTANCE.skybox.mesh, RENDERER_INSTANCE.skybox.texture)
}

renderer_prepare_drawing :: proc() {
	gfx.pipeline_clear(RENDERER_INSTANCE.full_block_solid_pipeline)
}
