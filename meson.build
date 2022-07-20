project('project_amber', 'c', 'cpp',
    default_options : ['c_std=c17', 'cpp_std=c++23'],
    version: '0.0.1'
)

add_global_arguments('-DVX_PLATFORM_WINDOWS=1', language : 'cpp')

lib_vx_utils = subproject('vx_utils')
lib_vx_utils_dep = lib_vx_utils.get_variable('lib_vx_utils_dep')

lib_vx_lib = subproject('vx_lib')
lib_vx_lib_dep = lib_vx_lib.get_variable('lib_vx_lib_dep')

lib_glfw = subproject('glfw')
lib_glfw_dep = lib_glfw.get_variable('lib_glfw_dep')

lib_bgfx = subproject('bgfx')
lib_bgfx_dep = lib_bgfx.get_variable('lib_bgfx_dep')

lib_fastnoise = subproject('fastnoise')
lib_fastnoise_dep = lib_fastnoise.get_variable('lib_fastnoise_dep')

executable('project_amber',
    'src/main.cpp',
#    dependencies : [ lib_vx_utils_dep, lib_glfw_dep, lib_vx_lib_dep ],
    dependencies : [ lib_vx_utils_dep, lib_glfw_dep, lib_vx_lib_dep, lib_bgfx_dep, lib_fastnoise_dep ],
    link_args: [ '-static-libgcc' ],
    install : true
)