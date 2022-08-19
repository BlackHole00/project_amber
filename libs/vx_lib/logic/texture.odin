package vx_lib_logic

import "../gfx"
import "../common"
import gl "vendor:OpenGL"

Texture_Component :: gfx.Texture
Skybox_Texture_Component :: Texture_Component

skybox_init :: proc(mesh: ^Mesh_Component, texture: ^gfx.Texture, right_path, left_path, top_path, bottom_path, back_path, front_path: string) {
    meshcomponent_init(mesh, Mesh_Descriptor {
		index_buffer_type = gl.UNSIGNED_INT,
		gl_usage = gl.STATIC_DRAW,
		gl_draw_mode = gl.TRIANGLES,
		draw_to_depth_buffer = false,
	}, common.CUBE_VERTICES, common.CUBE_INDICES)

    gfx.texture_init(texture, gfx.Texture_Descriptor {
		gl_type = gl.TEXTURE_CUBE_MAP,
		internal_texture_format = gl.RGBA,
		texture_unit = 0,
		warp_s = gl.REPEAT,
		warp_t = gl.REPEAT,
		min_filter = gl.NEAREST,
		mag_filter = gl.NEAREST,
		gen_mipmaps = false,
	}, right_path, left_path, top_path, bottom_path, back_path, front_path)
}

skybox_get_bindings :: proc(mesh: Mesh_Component, texture: Skybox_Texture_Component, bindings: ^gfx.Bindings, skyblock_uniform := gfx.SKYBOX_UNIFORM_NAME) {
	meshcomponent_get_bindings(mesh, []gfx.Texture_Binding {
		{
			texture = texture,
			uniform_name = skyblock_uniform,
		},
	}, bindings)
}

skybox_draw :: proc(pipeline: ^gfx.Pipeline, mesh: Mesh_Component, texture: Skybox_Texture_Component, skyblock_uniform := gfx.SKYBOX_UNIFORM_NAME) {
	meshcomponent_draw(mesh, pipeline, []gfx.Texture_Binding {
		{
			texture = texture,
			uniform_name = skyblock_uniform,
		},
	})
}
