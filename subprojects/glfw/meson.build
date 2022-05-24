project('lib_glfw', 'c')

inc = include_directories('include')

lib_glfw_dep = declare_dependency(
    include_directories : inc,
    objects: [ 'lib/libglfw3.a' ]
    #link_args: [ 
    #    '-L' + meson.current_source_dir() + '/lib', 
    #    '-lglfw3'
    #]
)