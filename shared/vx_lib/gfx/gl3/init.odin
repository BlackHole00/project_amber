package vx_lib_gfx_gl3

import "core:mem"
import cl "shared:OpenCL"
import "shared:glfw"
import "shared:vx_lib/gfx"
import core "shared:vx_core"

Context_Descriptor :: struct {
    glfw_window: glfw.WindowHandle,
    vsync: bool,
    version: [2]int,
}

@(private)
Ubo_Bindning_Point_State :: enum byte {
    Available = 0,
    Used      = 1,
}

@(private)
Context :: struct {
    gl_allocator: mem.Allocator,
    gl_version: [2]int,

    ubo_binding_point_states: [dynamic]Ubo_Bindning_Point_State,

    device: cl.device_id,
    cl_context: cl.cl_context,
    queue: cl.command_queue,
}
@(private)
CONTEXT: core.Cell(Context)

init :: proc(desc: Context_Descriptor, allocator: mem.Allocator) {
    when ODIN_DEBUG do if !core.cell_is_valid(gfx.GFXPROCS_INSTANCE) do panic("vx_lib/gfx/gl3.init must be called only after vx_lib/gfx/gfxprocs_init.")

    core.cell_init(&CONTEXT, allocator)

    opengl_init(desc, allocator)
    opencl_init()

    init_gfx_procs()
}

deinit :: proc(free_all_mem := false) {
    opencl_deinit()
    opengl_deinit()

    if free_all_mem do mem.free_all(CONTEXT.gl_allocator)

    core.cell_free(&CONTEXT)
}

init_gfx_procs :: proc() {
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.buffer_new_empty, buffer_new_empty)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.buffer_new_with_data, buffer_new_with_data)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.buffer_free, buffer_free)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.buffer_set_data, buffer_set_data)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.bindings_new, bindings_new)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.bindings_free, bindings_free)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE._internal_texture_new_no_size, _internal_texture_new_no_size)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_new_with_size_1d, texture_new_with_size_1d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_new_with_size_2d, texture_new_with_size_2d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_new_with_size_3d, texture_new_with_size_3d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_new_with_data_1d, texture_new_with_data_1d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_new_with_data_2d, texture_new_with_data_2d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_new_with_data_3d, texture_new_with_data_3d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_free, texture_free)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_set_data_1d, texture_set_data_1d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_set_data_2d, texture_set_data_2d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_set_data_3d, texture_set_data_3d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_set_data_cubemap_face, texture_set_data_cubemap_face)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_resize_1d, texture_resize_1d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_resize_2d, texture_resize_2d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_resize_3d, texture_resize_3d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_copy_1d, texture_copy_1d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_copy_2d, texture_copy_2d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.texture_copy_3d, texture_copy_3d)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_new, pipeline_new)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_free, pipeline_free)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_resize, pipeline_resize)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_clear, pipeline_clear)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_set_wireframe, pipeline_set_wireframe)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_draw_arrays, pipeline_draw_arrays)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_draw_elements, pipeline_draw_elements)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_draw_arrays_instanced, pipeline_draw_arrays_instanced)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_draw_elements_instanced, pipeline_draw_elements_instanced)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_uniform_1f, pipeline_uniform_1f)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_uniform_2f, pipeline_uniform_2f)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_uniform_3f, pipeline_uniform_3f)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_uniform_4f, pipeline_uniform_4f)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_uniform_mat4f, pipeline_uniform_mat4f)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.pipeline_uniform_1i, pipeline_uniform_1i)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.framebuffer_new, framebuffer_new)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.framebuffer_new_from_textures, framebuffer_new_from_textures)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.framebuffer_free, framebuffer_free)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.framebuffer_resize, framebuffer_resize)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.framebuffer_get_color_texture_bindings, framebuffer_get_color_texture_bindings)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.framebuffer_get_depth_stencil_texture_bindings, framebuffer_get_depth_stencil_texture_bindings)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computebuffer_new_empty, computebuffer_new_empty)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computebuffer_new_with_data, computebuffer_new_with_data)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computebuffer_new_from_buffer, computebuffer_new_from_buffer)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computebuffer_new_from_texture, computebuffer_new_from_texture)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computebuffer_free, computebuffer_free)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computebuffer_update_bound_texture, computebuffer_update_bound_texture)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computebuffer_update_bound_buffer, computebuffer_update_bound_buffer)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computebuffer_set_data, computebuffer_set_data)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computebuffer_get_data, computebuffer_get_data)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computepipeline_new, computepipeline_new)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computepipeline_free, computepipeline_free)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computepipeline_set_local_work_size, computepipeline_set_local_work_size)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computepipeline_set_global_work_size, computepipeline_set_global_work_size)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computepipeline_compute, computepipeline_compute)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computebindings_new, computebindings_new)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computebindings_free, computebindings_free)
    core.assign_proc(&gfx.GFXPROCS_INSTANCE.computebindings_set_element, computebindings_set_element)
}