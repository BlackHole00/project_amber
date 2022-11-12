package main

import "../libs/bindgen"
import "core:os"
import "core:io"
import "core:bufio"
import "core:c/libc"
import "core:fmt"

main :: proc() {
    clear_webgpu_header()
    defer cleanup()

    options : bindgen.GeneratorOptions
    options.mode = "odin"

    // We remove defines' prefix.
    //options.definePrefixes = []string{"VK_"};
    //options.defineCase = bindgen.Case.Constant;

    // Pseudo types are everything that can act as a type,
    // enum, struct, unions. In vulkan.h, they are all prefixed
    // with Vk, we remove that.
    options.pseudoTypePrefixes = []string{"Wgpu", "WGPU", "wgpu"}
    //options.pseudoTypeTransparentPrefixes = []string{"PFN_"};
    options.pseudoTypeCase = bindgen.Case.Pascal
    options.variableCase = bindgen.Case.Snake

    // In the C header, functions look like vkCreateInstance(), we remove the prefix.
    options.functionPrefixes = []string{"Wgpu", "WGPU", "wgpu"}
    options.functionCase = bindgen.Case.Snake

    // In vulkan headers, enum like VkDebugReportObjectTypeEXT
    // have values names such as VK_DEBUG_REPORT_OBJECT_TYPE_INSTANCE_EXT.
    // With the following options, we will remove the repeated "VK_DEBUG_REPORT_OBJECT_TYPE_"
    // from the enum value. Notice the "EXT" part being projected at the end,
    // thus it is configured as a postfix below.
    // Generated value will be accessible with vk.DebugReportObjectTypeEXT.Instance,
    // this follow vulkan.hpp project convention.
    options.enumValuePrefixes = []string{"Wgpu", "WGPU", "wgpu"};
    //options.enumValuePostfixes = []string{"_BIT", "BEGIN_RANGE", "END_RANGE", "RANGE_SIZE", "MAX_ENUM"};
    //options.enumValueTransparentPostfixes = []string{"_KHR", "_EXT", "_AMD", "_NV", "_NVX", "_IMG", "_GOOGLE"};
    options.enumValueCase = bindgen.Case.Pascal;
    options.enumValueNameRemove = true;
    //options.enumValueNameRemovePostfixes = []string{"FlagBits", "EXT", "KHR", "AMD", "NV", "NVX", "IMG", "GOOGLE"};
    //options.enumConsideredFlagsPostfixes = []string{"FlagBits", "FlagBitsEXT", "FlagBitsKHR", "FlagBitsAMD", "FlagBitsNV", "FlagBitsNVX", "FlagBitsIMG", "FlagBitsGOOGLE"};

    // Vulkan header has some weird macros, we handle these here.
    //options.parserOptions.customHandlers["VK_DEFINE_HANDLE"] = macro_define_handle;
    //options.parserOptions.customHandlers["VK_DEFINE_NON_DISPATCHABLE_HANDLE"] = macro_define_handle;
    //options.parserOptions.customExpressionHandlers["VK_MAKE_VERSION"] = macro_make_version;

    // Vulkan also has platform-dependent defines that are confusing when parsing,
    // we remove them here.
    options.parserOptions.ignoredTokens = []string{"WGPU_EXPORT"}

    // Here, we effectively generate the file from vulkan_core.h only.
    // Platform-dependent APIs are in different headers.
    bindgen.generate(
        packageName = "wgpu",
        foreignLibrary = "wgpu_native.lib",
        outputFile = "../libs/wgpu/wgpu.odin",
        headerFiles = []string{"../libs/wgpu/wgpu-native/ffi/wgpu.h"},
        options = options,
    )

    bindgen.generate(
        packageName = "wgpu",
        foreignLibrary = "wgpu_native.lib",
        outputFile = "../libs/wgpu/wgpu.odin",
        headerFiles = []string{"../libs/wgpu/wgpu-native/ffi/webgpu-headers/webgpu.h"},
        options = options,
    )
}

clear_webgpu_header :: proc() {
    libc.system(`copy ..\libs\wgpu\wgpu-native\ffi\webgpu-headers\webgpu.h ..\libs\wgpu\wgpu-native\ffi\webgpu-headers\webgpu.h.bak`)

    data: []byte = ---
    defer delete(data)
    {
        handle, err := os.open("../libs/wgpu/wgpu-native/ffi/webgpu-headers/webgpu.h", os.O_RDONLY)
        defer os.close(handle)
        assert(err == 0, "Could not open webgpu.h file")

        stream := os.stream_from_handle(handle)

        reader := io.to_reader(stream)
        new_line_count := 0
        char_count := 0
        for new_line_count != 49 {
            char, err := io.read_byte(reader)
            assert(err == .None, "Failed to read file")

            if char == '\n' do new_line_count += 1
            char_count += 1
        }

        data = make([]byte, io.size(stream) - (i64)(char_count) + 1)
        io.read_at(io.to_reader_at(reader), data, (i64)(char_count))
    }

    libc.system(`del ..\libs\wgpu\wgpu-native\ffi\webgpu-headers\webgpu.h`)

    {
        handle, err := os.open("../libs/wgpu/wgpu-native/ffi/webgpu-headers/webgpu.h", os.O_CREATE | os.O_WRONLY)
        defer os.close(handle)
        assert(err == 0, "Could not open webgpu.h file")

        stream := os.stream_from_handle(handle)

        writer: bufio.Writer = --- 
        bufio.writer_init(&writer, io.to_writer(stream), len(data))
        fmt.println(bufio.writer_write(&writer, data[:len(data) - 1]))
        bufio.writer_flush(&writer)
        bufio.writer_destroy(&writer)
    }
}

cleanup :: proc() {
    libc.system(`del ..\libs\wgpu\wgpu-native\ffi\webgpu-headers\webgpu.h`)
    libc.system(`copy ..\libs\wgpu\wgpu-native\ffi\webgpu-headers\webgpu.h.bak ..\libs\wgpu\wgpu-native\ffi\webgpu-headers\webgpu.h`)
    libc.system(`del ..\libs\wgpu\wgpu-native\ffi\webgpu-headers\webgpu.h.bak`)
}