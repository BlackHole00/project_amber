project('lib_vx_lib', 'cpp')

inc = include_directories('src')

lib_glfw = subproject('glfw')
lib_glfw_dep = lib_glfw.get_variable('lib_glfw_dep')

lib_vx_utils = subproject('vx_utils')
lib_vx_utils_dep = lib_vx_utils.get_variable('lib_vx_utils_dep')

lib_bgfx = subproject('bgfx')
lib_bgfx_dep = lib_bgfx.get_variable('lib_bgfx_dep')


lib = static_library('vx_lib',
    'src/vx_lib/os/window.cpp',
    'src/vx_lib/os/window_context.cpp',
    'src/vx_lib/os/context/bgfx_context.cpp',
    'src/vx_lib/os/window_helper.cpp',
    'src/vx_lib/gfx/bgfx/shader_utils.cpp',
    'src/vx_lib/logic/components/camera.cpp',
    'src/vx_lib/logic/components/transform/transform.cpp',
    'src/vx_lib/utils/math/vector_helpers.cpp',
    dependencies: [ lib_vx_utils_dep, lib_glfw_dep, lib_bgfx_dep ],
    include_directories : inc,
    install : true
)

lib_vx_lib_dep = declare_dependency(
    dependencies: [ lib_vx_utils_dep, lib_glfw_dep, lib_bgfx_dep ],
    include_directories : inc,
    link_with : lib
)
