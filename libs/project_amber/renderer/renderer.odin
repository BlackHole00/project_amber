package project_amber_renderer

import "core:os"
import "vx_lib:core"
import "vx_lib:gfx"
import "vx_lib:logic"
import "vx_lib:utils"
import "vx_lib:platform"
import gl "vendor:OpenGL"

BLOCK_TEXTURE_ATLAS_UNIFORM :: "uBlockTextureAtlas"

Renderer :: struct {
    block_texture_atlas: utils.Texture_Atlas,

    full_block_solid_pipeline: gfx.Pipeline,
}
RENDERER_INSTANCE: core.Cell(Renderer)

renderer_init :: proc() {
    core.cell_init(&RENDERER_INSTANCE)

    // TODO: make textureatlas dynamic and register textures at runtime.
    utils.textureatlas_init(&RENDERER_INSTANCE.block_texture_atlas, utils.Texture_Atlas_Descriptor {
        internal_texture_format = gl.RGB8,
        warp_s = gl.CLAMP_TO_BORDER,
        warp_t = gl.CLAMP_TO_BORDER,
        min_filter = gl.NEAREST,
        mag_filter = gl.NEAREST,
        gen_mipmaps = true,
    }, "res/project_amber/textures/block_atlas.png", "res/project_amber/textures/block_atlas.csv")

    vertex_src, ok := os.read_entire_file("res/project_amber/shaders/full_solid_block.vs")
	if !ok do panic("Could not open vertex shader file")
    defer delete(vertex_src)

	fragment_src, ok2 := os.read_entire_file("res/project_amber/shaders/full_solid_block.fs")
	if !ok2 do panic("Could not open fragment shader file")
    defer delete(fragment_src)

    window_size := platform.windowhelper_get_window_size()
    gfx.pipeline_init(&RENDERER_INSTANCE.full_block_solid_pipeline, gfx.Pipeline_Descriptor {
        cull_enabled = true,
        cull_face = gl.BACK,
        cull_front_face = gl.CCW,

        depth_enabled = true,
        depth_func = gl.LEQUAL,

        blend_enabled = false,

        wireframe = false,

        viewport_size = window_size,

        clear_color = false,
        clear_depth = false,

        layout = WORLD_VERTEX_LAYOUT,

        vertex_source = (string)(vertex_src),
        fragment_source = (string)(fragment_src),
    })
}

renderer_update_camera :: proc(camera: logic.Camera_Component, position: logic.Position_Component, rotation: logic.Rotation_Component) {
    logic.camera_apply(camera, position, rotation, &RENDERER_INSTANCE.full_block_solid_pipeline)
}

renderer_resize :: proc(size: [2]uint) {
    gfx.pipeline_resize(&RENDERER_INSTANCE.full_block_solid_pipeline, size)
}
