project('lib_vx_utils', 'c')

inc = include_directories('src')
lib = static_library('vx_utils',
    'src/vx_utils/file.c',
    'src/vx_utils/functions.c',
    'src/vx_utils/mem.c',
    'src/vx_utils/panic.c',
    include_directories : inc,
    install : true
)

lib_vx_utils_dep = declare_dependency(include_directories : inc, link_with : lib)
