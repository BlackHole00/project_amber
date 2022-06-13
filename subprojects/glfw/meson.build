project('lib_glfw', 'cpp')

inc = include_directories('include')

lib_glfw_dep = declare_dependency(
    include_directories : inc,
    link_args: [ 
        '-L' + meson.current_source_dir() + '/lib', 
        '-lglfw3'
    ]
)