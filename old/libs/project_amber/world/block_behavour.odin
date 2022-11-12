package project_amber_world

import "vx_lib:logic"

@(private)
Mesh_Texture_Modifiers_Bits :: enum {
    Natural_Flip_X,
    Natural_Flip_Y,
}

Mesh_Texture_Modifiers :: bit_set[Mesh_Texture_Modifiers_Bits]

Full_Block_Mesh_Single_Texture :: struct {
    texture: string,
    modifiers: Mesh_Texture_Modifiers,
}

Full_Block_Mesh_Multi_Texture :: [6]Full_Block_Mesh_Single_Texture // Top, bottom, left, right, front, back

Full_Block_Mesh_Texturing :: union {
    Full_Block_Mesh_Single_Texture,
    Full_Block_Mesh_Multi_Texture,
}

Full_Block_Mesh :: struct {
    texturing: Full_Block_Mesh_Texturing,
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