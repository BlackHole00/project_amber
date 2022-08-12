package vx_lib_gfx

INVALID_HANDLE :: 0

VIEW_UNIFORM_NAME :: "uView"
PROJ_UNIFORM_NAME :: "uProj"

bind :: proc {
    buffer_bind,
    layout_bind,
    pipeline_bind,
    shader_bind,
    texturebundle_bind,
    texture_bind,
}

apply :: proc {
    texturebundle_apply,
    texture_apply,
}
