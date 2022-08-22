package vx_lib_gfx_immediate

import "../../utils"
import "../../gfx"
import "core:fmt"

push_triangle :: proc(vertices: []Color_Vertex) {
    utils.batcher_push_triangle(&CONTEXT_INSTANCE.color_batcher, vertices)
}

push_quad :: proc(vertices: []Color_Vertex) {
    utils.batcher_push_quad(&CONTEXT_INSTANCE.color_batcher, vertices)
}

push_char :: proc(pos: [2]f32, size: [2]f32, char: rune) {
    rune_to_identstring :: proc(char: rune) -> string {
        return fmt.aprint(args = { "char_", (i32)(char) }, sep = "")
    }

    ident := rune_to_identstring(char)
    defer delete(ident)

    top, bottom, left, right := utils.textureatlas_get_uv(&CONTEXT_INSTANCE.font_atlas, ident)

    utils.batcher_push_quad(&CONTEXT_INSTANCE.textured_batcher, []Textured_Vertex {
        {
            position = { pos.x,          pos.y,          0.0 }, uv = { left, bottom },
        },
        {
            position = { pos.x,          pos.y + size.y, 0.0 }, uv = { left, top },
        },
        {
            position = { pos.x + size.x, pos.y + size.y, 0.0 }, uv = { right, top },
        },
        {
            position = { pos.x + size.x, pos.y,          0.0 }, uv = { right, bottom },
        },
    })
}

push_string :: proc(pos: [2]f32, char_size: [2]f32, str: string) {
    current_x := pos.x

    for char in str {
        push_char({ current_x, pos.y }, char_size, char)

        current_x += char_size.x
    }
}

resize_viewport :: proc(viewport: [2]uint) {
    gfx.pipeline_resize(&CONTEXT_INSTANCE.color_pipeline, viewport)
    gfx.pipeline_resize(&CONTEXT_INSTANCE.textured_pipeline, viewport)
}

draw :: proc() {
    utils.batcher_draw(&CONTEXT_INSTANCE.color_batcher, &CONTEXT_INSTANCE.color_pipeline)
    utils.batcher_draw(&CONTEXT_INSTANCE.textured_batcher, &CONTEXT_INSTANCE.textured_pipeline)

    utils.batcher_clear(&CONTEXT_INSTANCE.color_batcher)
    utils.batcher_clear(&CONTEXT_INSTANCE.textured_batcher)
}
