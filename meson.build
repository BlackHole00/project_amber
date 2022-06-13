project('project_amber', 'c')

lib_vx_utils = subproject('vx_utils')
lib_vx_utils_dep = lib_vx_utils.get_variable('lib_vx_utils_dep')

lib_vx_lib = subproject('vx_lib')
lib_vx_lib_dep = lib_vx_lib.get_variable('lib_vx_lib_dep')

lib_stb = subproject('stb')
lib_stb_dep = lib_stb.get_variable('lib_stb_dep')

lib_glfw = subproject('glfw')
lib_glfw_dep = lib_glfw.get_variable('lib_glfw_dep')

lib_wgpu = subproject('wgpu')
lib_wgpu_dep = lib_wgpu.get_variable('lib_wgpu_dep')

executable('project_amber',
    'src/main.cpp',
    default_options : ['cpp_std=c++23'],
    dependencies : [ lib_vx_utils_dep, lib_glfw_dep, lib_stb_dep, lib_vx_lib_dep ],
    #dependencies : [ lib_vx_utils_dep, lib_vx_lib_dep, lib_glfw_dep, lib_wgpu_dep, lib_stb_dep ],
    link_args: [ '-static-libgcc' ],
    install : true
)