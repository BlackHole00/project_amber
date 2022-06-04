project('lib_vx_lib', 'cpp')

inc = include_directories('src')

lib_glfw = subproject('glfw')
lib_glfw_dep = lib_glfw.get_variable('lib_glfw_dep')

lib_vx_utils = subproject('vx_utils')
lib_vx_utils_dep = lib_vx_utils.get_variable('lib_vx_utils_dep')

lib_wgpu = subproject('wgpu')
lib_wgpu_dep = lib_wgpu.get_variable('lib_wgpu_dep')

lib = static_library('vx_lib',
    #'src/vx_lib/os/window.c',
    #'src/vx_lib/os/window_context.c',
    #'src/vx_lib/os/context/wgpu.c',
    #'src/vx_lib/gfx/wgpu_utils.c',
    dependencies: [ lib_vx_utils_dep, lib_glfw_dep, lib_wgpu_dep ],
    include_directories : inc,
    install : true
)

lib_vx_lib_dep = declare_dependency(
    dependencies: [ lib_vx_utils_dep, lib_glfw_dep, lib_wgpu_dep ],
    include_directories : inc,
    link_with : lib
)
