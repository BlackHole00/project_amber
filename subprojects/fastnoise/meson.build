project('lib_fastnoise', 'cpp')

inc = include_directories('include')
lib = static_library('fastnoise',
    'src/fast_noise_lite_impl.cpp',
    include_directories : inc,
    install : true
)

lib_fastnoise_dep = declare_dependency(include_directories : inc, link_with : lib)