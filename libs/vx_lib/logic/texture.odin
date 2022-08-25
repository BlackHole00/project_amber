package vx_lib_logic

import "../gfx"
import "../math"
import gl "vendor:OpenGL"

Texture_Component :: gfx.Texture
Skybox_Texture_Component :: Texture_Component

skybox_init :: proc(mesh: ^Mesh_Component, texture: ^gfx.Texture, right_path, left_path, top_path, bottom_path, front_path, back_path: string) {
    meshcomponent_init(mesh, Mesh_Descriptor {
		index_buffer_type = gl.UNSIGNED_INT,
		gl_usage = gl.STATIC_DRAW,
		gl_draw_mode = gl.TRIANGLES,
	}, math.CUBE_VERTICES, math.CUBE_INDICES)

    gfx.texture_init(texture, gfx.Texture_Descriptor {
		gl_type = gl.TEXTURE_CUBE_MAP,
		internal_texture_format = gl.RGBA8,
		warp_s = gl.CLAMP_TO_EDGE,
		warp_t = gl.CLAMP_TO_EDGE,
		min_filter = gl.LINEAR,
		mag_filter = gl.LINEAR,
		gen_mipmaps = false,
	}, right_path, left_path, top_path, bottom_path, back_path, front_path)
}

skybox_get_bindings :: proc(mesh: Mesh_Component, texture: Skybox_Texture_Component, bindings: ^gfx.Bindings, skyblock_uniform := gfx.SKYBOX_UNIFORM_NAME) {
	meshcomponent_get_bindings(
		bindings, 
		mesh, 
		[]gfx.Texture_Binding {
			{
				texture = texture,
				uniform_name = skyblock_uniform,
			},
		},
	)
}

skybox_draw :: proc(pipeline: ^gfx.Pipeline, mesh: Mesh_Component, texture: Skybox_Texture_Component, skyblock_uniform := gfx.SKYBOX_UNIFORM_NAME) {
	meshcomponent_draw(mesh, pipeline, []gfx.Texture_Binding {
		{
			texture = texture,
			uniform_name = skyblock_uniform,
		},
	})
}
