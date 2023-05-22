package glslang

when ODIN_OS == .Windows {
	when ODIN_ARCH == .amd64 {
        foreign import glslang { 
            "lib/GenericCodeGen.lib",
            "lib/glslang-default-resource-limits.lib",
            "lib/glslang.lib",
            "lib/HLSL.lib",
            "lib/MachineIndependent.lib",
            "lib/OGLCompiler.lib",
            "lib/OSDependent.lib",
            "lib/SPIRV-Tools-diff.lib",
            "lib/SPIRV-Tools-link.lib",
            "lib/SPIRV-Tools-lint.lib",
            "lib/SPIRV-Tools-opt.lib",
            "lib/SPIRV-Tools-reduce.lib",
            "lib/SPIRV-Tools-shared.lib",
            "lib/SPIRV-Tools.lib",
            "lib/SPIRV.lib",
            "lib/SPVRemapper.lib",
        }
    } else do #panic("Only 64 bit is supported")
} else do #panic("Only windows is supported")

@(default_calling_convention="c", link_prefix="glslang_")
foreign glslang {
    shader_create :: proc(input: rawptr) -> rawptr ---
}