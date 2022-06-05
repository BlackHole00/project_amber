//#include <wgpu.h>
//#include <webgpu.h>
//#include <stb_image.h>
//#include <vx_utils/utils.h>
//#include <vx_utils/loggers/stream_logger.h>
//#include <vx_lib/os/window_context.h>
//#include <vx_lib/os/context/wgpu.h>
//#include <vx_lib/os/window.h>
//#include <vx_lib/gfx/wgpu_utils.h>
//#include <float.h>
//
//class Test {
//    int a = 0;
//};
//
//const int WIDTH = 640;
//const int HEIGHT = 480;
//
//static void _handle_device_lost(WGPUDeviceLostReason reason, char const * message, void * userdata) {
//    vx_log(VX_LOGMESSAGELEVEL_FATAL, "DEVICE LOST (%d): %s\n", reason, message);
//}
//
//static void _handle_uncaptured_error(WGPUErrorType type, char const * message, void * userdata) {
//    vx_log(VX_LOGMESSAGELEVEL_FATAL, "WGPU UNCAPTURED ERROR (%d): %s\n", type, message);
//}
//
//typedef struct {
//    f32 position[3];
//    f32 uv[2];
//} Vertex;
//
//struct Vertex2 {
//    f32 pos;
//    f32 uv;
//};
//
//const Vertex VERTICES[4] = {
//    { {-0.5,-0.5, 0.0 }, { 0.0, 0.0 } },
//    { { 0.5,-0.5, 0.0 }, { 1.0, 0.0 } },
//    { { 0.5, 0.5, 0.0 }, { 1.0, 1.0 } },
//    { {-0.5, 0.5, 0.0 }, { 0.0, 1.0 } }
//};
//
//Vertex2 vert {
//    .pos = 10.0,
//    .uv = 10
//};
//
//const u32 INDICES[6] = {
//    0, 1, 2,
//    2, 3, 0
//};
//
//const WGPUVertexBufferLayout Vertex_BUFFER_LAYOUT {
//    .arrayStride = sizeof(Vertex),
//    .attributeCount = 2,
//    .attributes = (WGPUVertexAttribute[]) {
//        { .format = WGPUVertexFormat_Float32x3, .offset = 0,                .shaderLocation = 0 },
//        { .format = WGPUVertexFormat_Float32x2, .offset = sizeof(f32) * 3,  .shaderLocation = 1 }
//    },
//    .stepMode = WGPUVertexStepMode_Vertex,
//};
//
//typedef struct {
//    WGPUSurface surface;
//    WGPUAdapter adapter;
//    WGPUDevice device;
//    WGPUQueue queue;
//    WGPUSwapChain swap_chain;
//    WGPUTextureFormat swap_chain_format;
//    WGPUCommandEncoder encoder;
//    WGPURenderPipeline pipeline;
//    WGPUBuffer vertex_buffer;
//    WGPUBuffer index_buffer;
//    WGPUExtent3D texture_size;
//    WGPUTexture diffuse_texture;
//    WGPUBindGroup diffuse_texture_bind_group;
//} State;
//VX_CREATE_INSTANCE(State, STATE_INSTANCE);
//
//void init() {
//    STATE_INSTANCE.surface = VX_WGPUCONTEXT_INSTANCE.surface;
//
//    wgpuInstanceRequestAdapter(NULL, &(WGPURequestAdapterOptions) {
//        .compatibleSurface = STATE_INSTANCE.surface,
//        .powerPreference = WGPUPowerPreference_HighPerformance,
//        .forceFallbackAdapter = false,
//        .nextInChain = NULL,
//    }, request_adapter_callback, &STATE_INSTANCE.adapter);
//    VX_NULL_ASSERT(STATE_INSTANCE.adapter);
//
//    WGPUAdapterProperties properties;
//    wgpuAdapterGetProperties(STATE_INSTANCE.adapter, &properties);
//    printf("Using %s (adapter type %d, backend type %d)\n", properties.name, properties.adapterType, properties.backendType);
//
//    wgpuAdapterRequestDevice(STATE_INSTANCE.adapter, &(WGPUDeviceDescriptor) {
//        .nextInChain = (const WGPUChainedStruct*)&(WGPUDeviceExtras) {
//            .chain = (WGPUChainedStruct) {
//                .next = NULL,
//                .sType = WGPUSType_DeviceExtras,
//            },
//            .label = "Device",
//            .tracePath = NULL,
//        },
//        .requiredLimits =
//        &(WGPURequiredLimits) {
//            .nextInChain = NULL,
//            .limits = (WGPULimits){
//                .maxBindGroups = 1,
//            },
//        },
//    }, request_device_callback, &STATE_INSTANCE.device);
//    VX_NULL_ASSERT(STATE_INSTANCE.device);
//
//    wgpuDeviceSetUncapturedErrorCallback(STATE_INSTANCE.device, _handle_uncaptured_error, NULL);
//    wgpuDeviceSetDeviceLostCallback(STATE_INSTANCE.device, _handle_device_lost, NULL);
//
//    STATE_INSTANCE.swap_chain_format = wgpuSurfaceGetPreferredFormat(STATE_INSTANCE.surface, STATE_INSTANCE.adapter);
//
//    STATE_INSTANCE.swap_chain = wgpuDeviceCreateSwapChain(STATE_INSTANCE.device, STATE_INSTANCE.surface, &(WGPUSwapChainDescriptor) {
//        .usage = WGPUTextureUsage_RenderAttachment,
//        .format = STATE_INSTANCE.swap_chain_format,
//        .width = WIDTH,
//        .height = HEIGHT,
//        .presentMode = WGPUPresentMode_Immediate,
//    });
//    VX_NULL_ASSERT(STATE_INSTANCE.swap_chain);
//
//    STATE_INSTANCE.queue = wgpuDeviceGetQueue(STATE_INSTANCE.device);
//    VX_NULL_ASSERT(STATE_INSTANCE.queue);
//
//    int num_channels;
//    int img_width, img_height;
//    byte* img_data = stbi_load("res/dirt.png", &img_width, &img_height, &num_channels, 4);
//    STATE_INSTANCE.texture_size.depthOrArrayLayers = 1;
//    STATE_INSTANCE.texture_size.width = img_width;
//    STATE_INSTANCE.texture_size.height = img_height;
//    int img_size = STATE_INSTANCE.texture_size.width * STATE_INSTANCE.texture_size.width * num_channels;
//
//    STATE_INSTANCE.diffuse_texture = wgpuDeviceCreateTexture(STATE_INSTANCE.device, &(WGPUTextureDescriptor) {
//        .dimension = WGPUTextureDimension_2D,
//        .format = WGPUTextureFormat_RGBA8UnormSrgb,
//        .label = "diffuse_texture",
//        .mipLevelCount = 1,
//        .sampleCount = 1,
//        .usage = WGPUTextureUsage_TextureBinding | WGPUTextureUsage_CopyDst,
//        .size = STATE_INSTANCE.texture_size
//    });
//
//    wgpuQueueWriteTexture(STATE_INSTANCE.queue, &(WGPUImageCopyTexture) {
//        .texture = STATE_INSTANCE.diffuse_texture,
//        .mipLevel = 0,
//        .origin = (WGPUOrigin3D) { 0, 0, 0 },
//        .aspect = WGPUTextureAspect_All
//    }, img_data, img_size, &(WGPUTextureDataLayout) {
//        .bytesPerRow = num_channels * STATE_INSTANCE.texture_size.width,
//        .rowsPerImage = STATE_INSTANCE.texture_size.height,
//        .offset = 0
//    }, &STATE_INSTANCE.texture_size);
//    stbi_image_free(img_data);
//
//    WGPUTextureView diffuse_view = wgpuTextureCreateView(STATE_INSTANCE.diffuse_texture, &(WGPUTextureViewDescriptor) { 0 });
//    WGPUSampler diffuse_sampler = wgpuDeviceCreateSampler(STATE_INSTANCE.device, &(WGPUSamplerDescriptor) {
//        .addressModeU = WGPUAddressMode_ClampToEdge,
//        .addressModeV = WGPUAddressMode_ClampToEdge,
//        .addressModeW = WGPUAddressMode_ClampToEdge,
//        .magFilter = WGPUFilterMode_Nearest,
//        .minFilter = WGPUFilterMode_Nearest,
//        .mipmapFilter = WGPUFilterMode_Nearest,
//        .lodMinClamp = 0.0f,
//        .lodMaxClamp = FLT_MAX
//    });
//
//    WGPUBindGroupLayout diffuse_layout = wgpuDeviceCreateBindGroupLayout(STATE_INSTANCE.device, &(WGPUBindGroupLayoutDescriptor) {
//        .label = "diffuse_texture_bind_group",
//        .entryCount = 2,
//        .entries = (WGPUBindGroupLayoutEntry[]) {
//            {
//                .binding = 0,
//                .visibility = WGPUShaderStage_Fragment,
//                .texture = (WGPUTextureBindingLayout) {
//                    .multisampled = false,
//                    .sampleType = WGPUTextureSampleType_Float,
//                    .viewDimension = WGPUTextureViewDimension_2D
//                },
//            },
//            {
//                .binding = 1,
//                .visibility = WGPUShaderStage_Fragment,
//                .sampler = (WGPUSamplerBindingLayout) {
//                    .type = WGPUSamplerBindingType_Filtering
//                }
//            }
//        }
//    });
//
//    STATE_INSTANCE.diffuse_texture_bind_group = wgpuDeviceCreateBindGroup(STATE_INSTANCE.device, &(WGPUBindGroupDescriptor) {
//        .label = "diffuse_texture_bind_group",
//        .layout = diffuse_layout,
//        .entryCount = 2,
//        .entries = (WGPUBindGroupEntry[]) {
//            {
//                .binding = 0,
//                .textureView = diffuse_view
//            },
//            {
//                .binding = 1,
//                .sampler = diffuse_sampler
//            }
//        }
//    });
//
//    WGPUShaderModuleDescriptor shader_source = load_wgsl("res/shader.wgsl");
//    WGPUShaderModule shader_module = wgpuDeviceCreateShaderModule(STATE_INSTANCE.device, &shader_source);
//
//    WGPUPipelineLayout pipeline_layout = wgpuDeviceCreatePipelineLayout(STATE_INSTANCE.device, &(WGPUPipelineLayoutDescriptor){
//        .label = NULL,
//        .bindGroupLayoutCount = 1,
//        .bindGroupLayouts = &diffuse_layout,
//        .nextInChain = NULL,
//    });
//    STATE_INSTANCE.pipeline = wgpuDeviceCreateRenderPipeline(STATE_INSTANCE.device, &(WGPURenderPipelineDescriptor) {
//        .label = "pipeline",
//        .layout = pipeline_layout,
//        .vertex = (WGPUVertexState) {
//            .module = shader_module,
//            .entryPoint = "vs_main",
//            .bufferCount = 1,
//            .buffers = &Vertex_BUFFER_LAYOUT
//        },
//        .fragment = &(WGPUFragmentState) {
//            .module = shader_module,
//            .entryPoint = "fs_main",
//            .targetCount = 1,
//            .targets = &(WGPUColorTargetState) {
//                .format = STATE_INSTANCE.swap_chain_format,
//                .blend = &(WGPUBlendState){
//                    .color = (WGPUBlendComponent) {
//                        .srcFactor = WGPUBlendFactor_One,
//                        .dstFactor = WGPUBlendFactor_Zero,
//                        .operation = WGPUBlendOperation_Add,
//                    },
//                    .alpha = (WGPUBlendComponent) {
//                        .srcFactor = WGPUBlendFactor_One,
//                        .dstFactor = WGPUBlendFactor_Zero,
//                        .operation = WGPUBlendOperation_Add,
//                    }
//                },
//                .writeMask = WGPUColorWriteMask_All
//            },
//        },
//        .primitive = (WGPUPrimitiveState) {
//            .topology = WGPUPrimitiveTopology_TriangleList,
//            .stripIndexFormat = WGPUIndexFormat_Undefined,
//            .frontFace = WGPUFrontFace_CCW,
//            .cullMode = WGPUCullMode_None,
//        },
//        .multisample = (WGPUMultisampleState) {
//            .alphaToCoverageEnabled = false,
//            .count = 1,
//            .mask = ~0,
//            .nextInChain = NULL,
//        },
//        .depthStencil = NULL,
//    });
//    VX_NULL_ASSERT(STATE_INSTANCE.pipeline);
//
//    STATE_INSTANCE.vertex_buffer = wgpuDeviceCreateBuffer(STATE_INSTANCE.device, &(WGPUBufferDescriptor) {
//        .label = "vertex_buffer",
//        .usage = WGPUBufferUsage_Vertex,
//        .mappedAtCreation = true,
//        .size = sizeof(VERTICES)
//    });
//    Vertex* v_data = wgpuBufferGetMappedRange(STATE_INSTANCE.vertex_buffer, 0, sizeof(VERTICES));
//    memcpy(v_data, VERTICES, sizeof(VERTICES));
//    wgpuBufferUnmap(STATE_INSTANCE.vertex_buffer);
//
//    STATE_INSTANCE.index_buffer = wgpuDeviceCreateBuffer(STATE_INSTANCE.device, &(WGPUBufferDescriptor) {
//        .label = "index_buffer",
//        .usage = WGPUBufferUsage_Index,
//        .mappedAtCreation = true,
//        .size = sizeof(INDICES)
//    });
//    u32* i_data = wgpuBufferGetMappedRange(STATE_INSTANCE.index_buffer, 0, sizeof(INDICES));
//    memcpy(i_data, INDICES, sizeof(INDICES));
//    wgpuBufferUnmap(STATE_INSTANCE.index_buffer);
//}
//
//void logic(f64 delta) {
//
//}
//
//void draw() {
//    STATE_INSTANCE.encoder = wgpuDeviceCreateCommandEncoder(STATE_INSTANCE.device, &(WGPUCommandEncoderDescriptor){.label = "Command Encoder"});
//    VX_NULL_ASSERT(STATE_INSTANCE.encoder);
//
//    WGPUTextureView output = wgpuSwapChainGetCurrentTextureView(STATE_INSTANCE.swap_chain);
//    VX_NULL_ASSERT(output);
//
//    WGPURenderPassEncoder render_pass = wgpuCommandEncoderBeginRenderPass(STATE_INSTANCE.encoder, &(WGPURenderPassDescriptor) {
//        .colorAttachments = &(WGPURenderPassColorAttachment) {
//            .view = output,
//            .resolveTarget = 0,
//            .loadOp = WGPULoadOp_Clear,
//            .storeOp = WGPUStoreOp_Store,
//            .clearValue = (WGPUColor) {
//                .r = 0.1,
//                .g = 0.2,
//                .b = 0.3,
//                .a = 1.0,
//            },
//        },
//        .colorAttachmentCount = 1,
//        .depthStencilAttachment = NULL,
//    });
//
//    wgpuRenderPassEncoderSetPipeline(render_pass, STATE_INSTANCE.pipeline);
//    wgpuRenderPassEncoderSetIndexBuffer(render_pass, STATE_INSTANCE.index_buffer, WGPUIndexFormat_Uint32, 0, sizeof(INDICES));
//    wgpuRenderPassEncoderSetVertexBuffer(render_pass, 0, STATE_INSTANCE.vertex_buffer, 0, sizeof(VERTICES));
//    wgpuRenderPassEncoderSetBindGroup(render_pass, 0, STATE_INSTANCE.diffuse_texture_bind_group, 0, NULL);
//    //wgpuRenderPassEncoderDraw(render_pass, 3, 1, 0, 0);
//    wgpuRenderPassEncoderDrawIndexed(render_pass, 6, 1, 0, 0, 0);
//    wgpuRenderPassEncoderEnd(render_pass);
//
//    WGPUCommandBuffer cmd_buffer = wgpuCommandEncoderFinish(STATE_INSTANCE.encoder, &(WGPUCommandBufferDescriptor){ .label = NULL });
//    wgpuQueueSubmit(STATE_INSTANCE.queue, 1, &cmd_buffer);
//    wgpuSwapChainPresent(STATE_INSTANCE.swap_chain);
//}
//
//void close() {
//    wgpuBufferDestroy(STATE_INSTANCE.vertex_buffer);
//}
//
//int main() {
//    initializeLog();
//
//    vx_stream_logger_init(stdout, VX_LOGMESSAGELEVEL_DEBUG);
//
//    vx_windowcontext_init(vx_wgpucontext_init);
//
//    vx_WindowDescriptor desc = VX_DEFAULT(vx_WindowDescriptor);
//    desc.width      = WIDTH;
//    desc.height     = HEIGHT;
//    desc.show_fps_in_title = true;
//    desc.init_fn    = init;
//    desc.logic_fn   = logic;
//    desc.draw_fn    = draw;
//    desc.close_fn   = close;
//    vx_window_init(&desc);
//
//    vx_window_run();
//}
//

#include <stdio.h>
#include <vx_utils/utils.h>
#include <vx_utils/loggers/stream_logger.h>

#include <math.h>

typedef struct {
    float position[3] = { 1.0, 0.0, 0.0};
    float uv[2] = { 1.0, 0.0 };
} Vertex;
VX_CREATE_TO_STRING(Vertex,
    snprintf(buffer, size, "Vertex { { %f, %f, %f }, { %f, %f } }", ptr->position[0], ptr->position[1], ptr->position[2], ptr->uv[0], ptr->uv[1]);
)

int main() {
    vx::stream_logger_init(stdout, vx::LogMessageLevel::DEBUG);
    vx::allocator_stack_init();

    printf("%d\n", vx::default_value<int>());
    Vertex vertex = vx::default_value<Vertex>();

    char buffer[100];
    vx::to_string(&vertex, buffer, 100);
    printf("%s\n", buffer);

    vx::Vector<f32> vec = vx::vector_new<f32>();
    vx::Vector<f32> vec2 = vx::vector_new<f32>();

    vx::vector_push<f32>(&vec, 10);
    vx::vector_push<f32>(&vec, 20);
    vx::vector_push<f32>(&vec, 30);
    vx::vector_push<f32>(&vec, 40);

    vx::clone(&vec, &vec2);

    for (usize i = 0; i < vec.length; i++) {
        printf("%f %f\n", vec[i], vec2[i]);
    }

    vx::vector_free<f32>(&vec);
    vx::vector_free<f32>(&vec2);

    vx::stream_logger_free();
    vx::allocator_stack_free();
}