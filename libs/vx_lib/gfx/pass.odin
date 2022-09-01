package vx_lib_gfx

Pass_Descriptor :: struct {
    clear_color: bool,
    clearing_color: [4]f64,

    clear_depth: bool,

    viewport_size: [2]uint,
}

Pass :: struct {
    using desc: Pass_Descriptor,
    render_target: Maybe(Framebuffer),

    extra_data: rawptr,
}

pass_init :: proc(pass: ^Pass, desc: Pass_Descriptor, target: Maybe(Framebuffer) = nil) {
    GFX_PROCS.pass_init(pass, desc, target)
}

pass_begin :: proc(pass: ^Pass) {
    GFX_PROCS.pass_begin(pass)
}

pass_end :: proc(pass: ^Pass) {
    GFX_PROCS.pass_end(pass)
}

pass_resize :: proc(pass: ^Pass, size: [2]uint) {
    GFX_PROCS.pass_resize(pass, size)
}
