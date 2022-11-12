package vx_lib_logic

import "../gfx"
import "../math"

Texture_Component :: gfx.Texture
Skybox_Texture_Component :: Texture_Component

skybox_init :: proc(mesh: ^Mesh_Component, texture: ^gfx.Texture, right_path, left_path, top_path, bottom_path, front_path, back_path: string) {
    meshcomponent_init(mesh, Mesh_Descriptor {
		index_buffer_type = .U32,
		usage = .Static_Draw,
		draw_type = .Triangles,
	}, math.CUBE_VERTICES, math.CUBE_INDICES)

    gfx.texture_init(texture, gfx.Texture_Descriptor {
		type = .Texture_CubeMap,
		internal_texture_format = .R8G8B8A8,
		warp_s = .Clamp_To_Edge,
		warp_t = .Clamp_To_Edge,
		min_filter = .Linear,
		mag_filter = .Linear,
		gen_mipmaps = false,
	}, right_path, left_path, top_path, bottom_path, back_path, front_path)
}

skybox_free :: proc(mesh: ^Mesh_Component, texture: ^Skybox_Texture_Component) {
	meshcomponent_free(mesh)
	gfx.texture_free(texture)
}

skybox_get_bindings :: proc(mesh: Mesh_Component, texture: Skybox_Texture_Component, bindings: ^gfx.Bindings, skyblock_uniform: uint = gfx.SKYBOX_CUBEMAP_UNIFORM_LOCATION) {
	meshcomponent_get_bindings(
		bindings, 
		mesh, 
		[]gfx.Texture_Binding {
			{
				texture = texture,
				uniform_location = skyblock_uniform,
			},
		},
	)
}

skybox_draw :: proc(pipeline: ^gfx.Pipeline, mesh: Mesh_Component, texture: Skybox_Texture_Component, skyblock_uniform: uint = gfx.SKYBOX_CUBEMAP_UNIFORM_LOCATION) {
	meshcomponent_draw(mesh, pipeline, []gfx.Texture_Binding {
		{
			texture = texture,
			uniform_location = skyblock_uniform,
		},
	})
}
