package main

import "core:math/linalg/glsl"
import "shared:glfw"
import "shared:vx_lib/gfx"
import "shared:vx_lib/platform"
import "shared:vx_lib/common"
import core "shared:vx_core"

vertex_souce := `
#version 330 core

layout (location = 0) in vec3 a_pos;
layout (location = 1) in vec2 a_uv;

out vec2 v_uv;

void main() {
    gl_Position = vec4(a_pos, 1.0);
    v_uv = a_uv;
}
`

fragment_source := `
#version 330 core

uniform sampler2D u_texture;

in vec2 v_uv;

out vec4 o_color;

void main() {
    o_color = texture(u_texture, v_uv);
}
`

compute_source := `
float2 square_imaginary(float2 number){
    float2 res;
    res.x = pow(number.x, 2) - pow(number.y, 2);
    res.y = 2 * number.x * number.y;

    return res;
}

float iterate_mandelbrot(float2 coord, const int max_iterations){
    float2 z;
    z.x = 0.0;
    z.y = 0.0;

    for(int i = 0; i < max_iterations; i++) {
        z = square_imaginary(z) + coord;
        if(length(z) > 2) {
            return i / (float)(max_iterations);
        }
    }
    return 1.0;
}

__kernel void mandelbrot(write_only image2d_t out, const int max_iterations, const float rateo, const float zoom, const float2 pos) {
    int x = get_global_id(0);
    int y = get_global_id(1);

    int width = get_global_size(0);
    int height = get_global_size(1);

    float2 coord;
    //coord.x = ((x + pos.x) / (width  / zoom) - 1.0) * rateo;
    //coord.y = ((y + pos.y) / (height / zoom) - 0.5);
    coord.x = (((float)(x) / (float)(width)  - 0.5) / zoom + (pos.x / width  )) * rateo;
    coord.y = (((float)(y) / (float)(height) - 0.5) / zoom + (pos.y / height ));

    float value = iterate_mandelbrot(coord, max_iterations);

    write_imagef(out, (int2)(x, y), (float4)(
        value,
        value,
        value,
        1.0
    ));
}
`
MAX_ITERATIONS :: 5000
START_ITERATIONS :: 500
RESOLUTION_SCALE :: 1.0

State :: struct {
	v_buffer: gfx.Buffer,
	i_buffer: gfx.Buffer,
	bindings: gfx.Bindings,
	texture: gfx.Texture,
	pipeline: gfx.Pipeline,

    compute_buffer: gfx.Compute_Buffer,
    compute_bindings: gfx.Compute_Bindings,
    compute_pipeline: gfx.Compute_Pipeline,
    compute_sync: Maybe(gfx.Sync),

    pos: [2]f32,
    zoom: f32,
    max_iterations: f32,

    start_drag: [2]f64,
}
STATE: core.Cell(State)

init :: proc() {
	core.cell_init(&STATE)

    window_size := platform.windowhelper_get_window_size()
    real_size := [2]uint {
        (uint)((f64)(window_size.x) * RESOLUTION_SCALE),
        (uint)((f64)(window_size.y) * RESOLUTION_SCALE),
    }

	STATE.texture = gfx.texture_new(gfx.Texture_Descriptor {
		type = .Texture_2D,
		internal_texture_format = .R8G8B8A8,
		format = .R8G8B8A8,
		pixel_type = .UByte,
		warp_s = .Clamp_To_Border,
		warp_t = .Clamp_To_Border,
		min_filter = .Linear,
		mag_filter = .Linear,
		gen_mipmaps = false,
	}, real_size)

	STATE.compute_buffer = gfx.computebuffer_new_from_texture(gfx.Compute_Buffer_Descriptor {
		type = .Write_Only,
	}, STATE.texture)

	STATE.compute_pipeline = gfx.computepipeline_new(gfx.Compute_Pipeline_Descriptor {
		source = compute_source,
    	entry_point = "mandelbrot",

    	dimensions = 2,
    	global_work_sizes = real_size[:],
		local_work_sizes  = { 16, 16 },
	})

    STATE.compute_bindings = gfx.computebindings_new([]gfx.Compute_Bindings_Element {
		0 = gfx.Compute_Bindings_Buffer_Element { buffer = STATE.compute_buffer },
        1 = gfx.Compute_Bindings_I32_Element { value = (i32)(MAX_ITERATIONS) },
        2 = gfx.Compute_Bindings_F32_Element { value = (f32)(window_size.x) / (f32)(window_size.y) }, // rateo
        3 = gfx.Compute_Bindings_F32_Element { value = 1.0 }, // zoom
        4 = gfx.Compute_Bindings_2F32_Element { value = [2]f32{ 0, 0 }}, // pos
	})
    
	STATE.compute_sync = gfx.computepipeline_compute(STATE.compute_pipeline, STATE.compute_bindings)

    STATE.v_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
        type = .Vertex_Buffer,
        usage = .Static_Draw,
    }, []f32 {
        -1.0, -1.0, 1.0, 0.0, 0.0,
        -1.0,  1.0, 1.0, 0.0, 1.0,
         1.0,  1.0, 1.0, 1.0, 1.0,
         1.0, -1.0, 1.0, 1.0, 0.0,
    })
    STATE.i_buffer = gfx.buffer_new(gfx.Buffer_Descriptor {
        type = .Index_Buffer,
        usage = .Static_Draw,
        index_type = .U32,
    }, []u32 {
        0, 1, 2,
        2, 3, 0,
    })
    STATE.pipeline = gfx.pipeline_new(gfx.Pipeline_Descriptor {
        cull_enabled = false,
        depth_enabled = false,
        blend_enabled = false,
        wireframe = false,
        viewport_size = window_size,

        vertex_source = vertex_souce,
        fragment_source = fragment_source,

        layout = gfx.Pipeline_Layout {
            gfx.Layout_Element {
                type = .F32,
                count = 3,
                normalized = false,
                buffer_idx = 0,
                divisor = 0,
            },
            gfx.Layout_Element {
                type = .F32,
                count = 2,
                normalized = false,
                buffer_idx = 0,
                divisor = 0,
            },
        },

        clearing_color = { 1.0, 0.0, 0.0, 1.0 },
        clear_color = true,
    })
    STATE.bindings = gfx.bindings_new([]gfx.Buffer { STATE.v_buffer }, STATE.i_buffer, []gfx.Texture_Binding {
        gfx.Texture_Binding { uniform_name = "u_texture", texture = STATE.texture },
    }, {})

    STATE.pos = { 0.0, 0.0 }
    STATE.zoom = 1.0
    STATE.max_iterations = START_ITERATIONS
}

tick :: proc() {
	input_common()

    old_pos := STATE.pos
    old_zoom := STATE.zoom
    old_iter := STATE.max_iterations

    movement := 1.0 / STATE.zoom * (f32)(platform.windowhelper_get_delta_time()) * 0.5
    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_D).pressed do STATE.pos.x += movement
    else if platform.windowhelper_get_keyboard_keystate(glfw.KEY_A).pressed do STATE.pos.x -= movement
    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_W).pressed do STATE.pos.y += movement
    else if platform.windowhelper_get_keyboard_keystate(glfw.KEY_S).pressed do STATE.pos.y -= movement

    if platform.windowhelper_get_mouse_keystate(glfw.MOUSE_BUTTON_LEFT).pressed {
        STATE.pos.x += 1.0 / STATE.zoom * (f32)(platform.windowhelper_get_mouse_offset().x)
        STATE.pos.y -= 1.0 / STATE.zoom * (f32)(platform.windowhelper_get_mouse_offset().y)
    }

    STATE.zoom += (f32)(platform.windowhelper_get_scroll_offset().y) * STATE.zoom * 0.05

    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_R).just_pressed {
        STATE.zoom = 1.0
        STATE.pos = { 0.0, 0.0 }
    }

    // 8.3 in 120 fps
    if STATE.compute_sync != nil {
        if platform.windowhelper_get_ms() > 8.5 && STATE.max_iterations > 1 do STATE.max_iterations -= 1
        else if platform.windowhelper_get_ms() < 8.1 && STATE.max_iterations < MAX_ITERATIONS do STATE.max_iterations += 1
    }

    delta_move := STATE.pos - old_pos
    delta_move.x = abs(delta_move.x)
    delta_move.y = abs(delta_move.y)
    delta_zoom := abs(STATE.zoom - old_zoom)

    if glsl.length((glsl.vec2)(delta_move)) >= (1.0 / STATE.zoom) || delta_zoom >= STATE.zoom * 0.0025 || (i32)(old_iter) != (i32)(STATE.max_iterations) {
        gfx.computebindings_set_element(STATE.compute_bindings, 1, gfx.Compute_Bindings_I32_Element { value = (i32)(STATE.max_iterations) })
        gfx.computebindings_set_element(STATE.compute_bindings, 3, gfx.Compute_Bindings_F32_Element  { value = STATE.zoom })
        gfx.computebindings_set_element(STATE.compute_bindings, 4, gfx.Compute_Bindings_2F32_Element { value = STATE.pos })

        if STATE.compute_sync != nil { 
            gfx.sync_discart(STATE.compute_sync.?)
            STATE.compute_sync = nil
        }
        STATE.compute_sync = gfx.computepipeline_compute(STATE.compute_pipeline, STATE.compute_bindings)
    }
}

draw :: proc() {
    gfx.pipeline_clear(STATE.pipeline)

    if STATE.compute_sync != nil {
        gfx.sync_await(STATE.compute_sync.?)
        STATE.compute_sync = nil
    }
    gfx.pipeline_draw_elements(STATE.pipeline, STATE.bindings, .Triangles, 6)
}

close :: proc() {
    gfx.computepipeline_free(STATE.compute_pipeline)
    gfx.computebindings_free(STATE.compute_bindings)
    gfx.computebuffer_free(STATE.compute_buffer)
    if STATE.compute_sync != nil do gfx.sync_discart(STATE.compute_sync.?)

    gfx.pipeline_free(STATE.pipeline)
    gfx.bindings_free(STATE.bindings)
    gfx.buffer_free(STATE.v_buffer)
    gfx.buffer_free(STATE.i_buffer)
    gfx.texture_free(STATE.texture)

	core.cell_free(&STATE)
}

resize :: proc() {
    window_size := platform.windowhelper_get_window_size()
    real_size := [2]uint {
        (uint)((f64)(window_size.x) * RESOLUTION_SCALE),
        (uint)((f64)(window_size.y) * RESOLUTION_SCALE),
    }

	gfx.pipeline_resize(STATE.pipeline, window_size)
    gfx.computebindings_set_element(STATE.compute_bindings, 2, gfx.Compute_Bindings_F32_Element { value = (f32)(window_size.x) / (f32)(window_size.y) })
    gfx.computepipeline_set_global_work_size(STATE.compute_pipeline, real_size[:])

    if STATE.compute_sync != nil do gfx.sync_await(STATE.compute_sync.?)
    gfx.texture_resize_2d(STATE.texture, real_size, false)
    gfx.computebuffer_update_bound_texture(STATE.compute_buffer, STATE.texture)

    STATE.compute_sync = gfx.computepipeline_compute(STATE.compute_pipeline, STATE.compute_bindings)
}

main :: proc() {
	context = core.default_context()
	defer core.free_default_context()

	common.vx_lib_init()
	defer common.vx_lib_free()

	platform.platform_start()
	defer platform.platform_close()

	desc: platform.Window_Descriptor
	desc.title = "Window"
	desc.size = { 640, 480 }
	desc.decorated = true
	desc.show_fps_in_title = true
	desc.init_proc = init
	desc.logic_proc = tick
	desc.draw_proc = draw
	desc.resize_proc = resize
	desc.close_proc = close
	desc.vsync = false
	desc.resizable = true
	desc.fullscreen = false

	platform.window_init(desc)
	defer platform.window_deinit()

	platform.window_run()
}

input_common :: proc() {
    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_TAB).just_pressed {
        platform.windowhelper_set_mouse_grabbbed(!platform.windowhelper_is_mouse_grabbed())
    }
    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_ESCAPE).just_pressed {
        platform.windowhelper_close_window()
    }

    if platform.windowhelper_get_keyboard_keystate(glfw.KEY_LEFT_ALT).pressed && platform.windowhelper_get_keyboard_keystate(glfw.KEY_F).just_pressed {
        @static not_fullscreen_size: [2]uint

        if !platform.windowhelper_is_fullscreen() {
            not_fullscreen_size = platform.windowhelper_get_window_size()

            platform.windowhelper_set_window_size(platform.windowhelper_get_screen_size())
        } else do platform.windowhelper_set_window_size(not_fullscreen_size)
        platform.windowhelper_set_fullscreen(!platform.windowhelper_is_fullscreen())
    }
}
