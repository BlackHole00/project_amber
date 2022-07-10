project('lib_bgfx', 'cpp')

make = find_program('make')
run_command(make, '-C', 'bgfx', 'mingw-gcc-debug64')

inc = include_directories([ 'bgfx/include' ])

lib_bgfx_dep = declare_dependency(include_directories : inc,
    link_args: [
        '-L' + meson.current_source_dir() + '/bgfx/.build/win64_mingw-gcc/bin', 
        '-lbgfxDebug',
        '-lbimg_decodeDebug',
        '-lbimg_encodeDebug',
        '-lbimgDebug',
        '-lbxDebug',
        '-lfcppDebug',
        '-lglslangDebug',
        '-lglsl-optimizerDebug',
        '-lspirv-crossDebug',
        '-lspirv-optDebug',
        '-lpsapi'
    ]
)
