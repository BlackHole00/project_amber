project('lib_vx_utils', 'cpp')

inc = include_directories('src')
lib = static_library('vx_utils',
    'src/vx_utils/file.cpp',
    'src/vx_utils/functions.cpp',
    'src/vx_utils/mem.cpp',
    'src/vx_utils/panic.cpp',
    'src/vx_utils/log.cpp',
    'src/vx_utils/loggers/stream_logger.cpp',
    include_directories : inc,
    install : true
)

lib_vx_utils_dep = declare_dependency(include_directories : inc, link_with : lib)
