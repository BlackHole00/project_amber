package vx_lib_logic

import "../gfx"
import "../math"

Texture_Component :: gfx.Texture
Skybox_Texture_Component :: Texture_Component

skybox_init :: proc(mesh: ^Mesh_Component, texture: ^gfx.Texture, right_path, left_path, top_path, bottom_path, front_path, back_path: string, skyblock_uniform := gfx.SKYBOX_UNIFORM_NAME) {
    texture^ = gfx.texture_new(gfx.Texture_Descriptor {
		type = .Texture_CubeMap,
		internal_texture_format = .R8G8B8A8,
		warp_s = .Clamp_To_Edge,
		warp_t = .Clamp_To_Edge,
		min_filter = .Linear,
		mag_filter = .Linear,
		gen_mipmaps = false,
	}, right_path, left_path, top_path, bottom_path, back_path, front_path)

	meshcomponent_init(mesh, Mesh_Descriptor {
		index_buffer_type = .U32,
		usage = .Static_Draw,
		draw_type = .Triangles,

		textures = []gfx.Texture_Binding{
			{ 
				uniform_name = skyblock_uniform,
				texture = texture^,
			},
		},
	}, math.CUBE_VERTICES, math.CUBE_INDICES)
}

skybox_free :: proc(mesh: ^Mesh_Component, texture: Skybox_Texture_Component) {
	meshcomponent_free(mesh)
	gfx.texture_free(texture)
}

skybox_draw :: proc(pipeline: gfx.Pipeline, mesh: Mesh_Component) {
	meshcomponent_draw(mesh, pipeline)
}
