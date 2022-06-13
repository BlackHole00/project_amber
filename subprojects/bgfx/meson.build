project('lib_bgfx', 'cpp')

inc = include_directories('src')
lib = static_library('bgfx',
    include_directories : inc,
    install : true
)

lib_vx_utils_dep = declare_dependency(include_directories : inc, link_with : lib)