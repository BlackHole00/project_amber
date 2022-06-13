project('lib_stb', 'cpp')

inc = include_directories('include')
lib = static_library('vx_utils',
    'src/implementation.cpp',
    include_directories : inc,
    install : true
)

lib_stb_dep = declare_dependency(include_directories : inc, link_with : lib)
