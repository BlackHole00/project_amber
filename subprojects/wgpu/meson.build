project('lib_wgpu', 'c')

inc = include_directories('src/ffi/webgpu-headers', 'src/ffi')

cargo = find_program('cargo')
run_command(cargo, 'build', '--release', '--manifest-path=src/Cargo.toml')

#mark cargo artifact to static library
#wgpu_native = static_library('wgpu_native',
#    objects : 'src/target/release/libwgpu_native.a',
#    install : true
#)

lib_wgpu_dep = declare_dependency(
    #link_with: wgpu_native,
    include_directories : inc,
    link_args: [ 
        '-L' + meson.current_source_dir() + '/src/target/release', 
        '-lwgpu_native'
    ]
)