package project_amber_world

import "vx_lib:logic"

@(private)
Full_Block_Mesh_Single_Texture :: string

@(private)
Full_Block_Mesh_Multi_Texture :: [6]string

Full_Block_Mesh_Texturing :: union {
    Full_Block_Mesh_Single_Texture,
    Full_Block_Mesh_Multi_Texture,
}

Full_Block_Mesh :: struct {
    texturing: Full_Block_Mesh_Texturing,
    natural_texture: bool,
}

Scripted_Block_Mesh :: struct {
    get_mesh_proc: proc(
        instance: Block_Instance,
        //world: World,
        mesh: ^logic.Abstract_Mesh,
    ),
}

Block_Mesh :: union {   // If nil -> Meshless
    Full_Block_Mesh,
    Scripted_Block_Mesh,
}

Block_Behaviour :: struct {
    solid: bool,

    mesh: Block_Mesh,
}