#include <wgpu.h>
#include <webgpu.h>
#include <vx_utils/utils.h>
#include <vx_lib/os/window_context.h>
#include <vx_lib/os/context/wgpu.h>
#include <vx_lib/os/window.h>
#include <vx_lib/gfx/wgpu_utils.h>

const int WIDTH = 640;
const int HEIGHT = 480;

static void _handle_device_lost(WGPUDeviceLostReason reason, char const * message, void * userdata) {
  printf("DEVICE LOST (%d): %s\n", reason, message);
}

static void _handle_uncaptured_error(WGPUErrorType type, char const * message, void * userdata) {
  printf("UNCAPTURED ERROR (%d): %s\n", type, message);
}

typedef struct {
    f32 position[3];
    f32 color[3];
} Vertex;

const Vertex VERTICES[4] = {
    { .position = {-0.5,-0.5, 0.0 }, .color = { 1.0, 0.0, 0.0 } },
    { .position = { 0.5,-0.5, 0.0 }, .color = { 0.0, 1.0, 0.0 } },
    { .position = { 0.5, 0.5, 0.0 }, .color = { 0.0, 0.0, 1.0 } },
    { .position = {-0.5, 0.5, 0.0 }, .color = { 0.0, 1.0, 0.0 } }
};

const u32 INDICES[6] = {
    0, 1, 2,
    2, 3, 0
};

const WGPUVertexBufferLayout Vertex_BUFFER_LAYOUT = {
    .arrayStride = sizeof(Vertex),
    .attributeCount = 2,
    .attributes = (WGPUVertexAttribute[]) {
        { .format = WGPUVertexFormat_Float32x3, .offset = 0,                .shaderLocation = 0 },
        { .format = WGPUVertexFormat_Float32x3, .offset = sizeof(f32) * 3,  .shaderLocation = 1 }
    },
    .stepMode = WGPUVertexStepMode_Vertex,
};

typedef struct {
    WGPUSurface surface;
    WGPUAdapter adapter;
    WGPUDevice device;
    WGPUQueue queue;
    WGPUSwapChain swap_chain;
    WGPUTextureFormat swap_chain_format;
    WGPUCommandEncoder encoder;
    WGPURenderPipeline pipeline;
    WGPUBuffer vertex_buffer;
    WGPUBuffer index_buffer;
} State;
VX_CREATE_INSTANCE(State, STATE_INSTANCE);

void init() {
    STATE_INSTANCE.surface = VX_WGPUCONTEXT_INSTANCE.surface;

    wgpuInstanceRequestAdapter(NULL, &(WGPURequestAdapterOptions) {
        .compatibleSurface = STATE_INSTANCE.surface,
        .powerPreference = WGPUPowerPreference_HighPerformance,
        .forceFallbackAdapter = false,
        .nextInChain = NULL,
    }, request_adapter_callback, &STATE_INSTANCE.adapter);
    VX_NULL_ASSERT(STATE_INSTANCE.adapter);

    WGPUAdapterProperties properties;
    wgpuAdapterGetProperties(STATE_INSTANCE.adapter, &properties);
    printf("Using %s (adapter type %d, backend type %d)\n", properties.name, properties.adapterType, properties.backendType);

    wgpuAdapterRequestDevice(STATE_INSTANCE.adapter, &(WGPUDeviceDescriptor) {
        .nextInChain = (const WGPUChainedStruct*)&(WGPUDeviceExtras) {
            .chain = (WGPUChainedStruct) {
                .next = NULL,
                .sType = WGPUSType_DeviceExtras,
            },
            .label = "Device",
            .tracePath = NULL,
        },
        .requiredLimits =
        &(WGPURequiredLimits) {
            .nextInChain = NULL,
            .limits = (WGPULimits){
                .maxBindGroups = 1,
            },
        },
    }, request_device_callback, &STATE_INSTANCE.device);
    VX_NULL_ASSERT(STATE_INSTANCE.device);

    wgpuDeviceSetUncapturedErrorCallback(STATE_INSTANCE.device, _handle_uncaptured_error, NULL);
    wgpuDeviceSetDeviceLostCallback(STATE_INSTANCE.device, _handle_device_lost, NULL);

    STATE_INSTANCE.swap_chain_format = wgpuSurfaceGetPreferredFormat(STATE_INSTANCE.surface, STATE_INSTANCE.adapter);

    STATE_INSTANCE.swap_chain = wgpuDeviceCreateSwapChain(STATE_INSTANCE.device, STATE_INSTANCE.surface, &(WGPUSwapChainDescriptor) {
        .usage = WGPUTextureUsage_RenderAttachment,
        .format = STATE_INSTANCE.swap_chain_format,
        .width = WIDTH,
        .height = HEIGHT,
        .presentMode = WGPUPresentMode_Immediate,
    });
    VX_NULL_ASSERT(STATE_INSTANCE.swap_chain);

    STATE_INSTANCE.queue = wgpuDeviceGetQueue(STATE_INSTANCE.device);
    VX_NULL_ASSERT(STATE_INSTANCE.queue);

    WGPUShaderModuleDescriptor shader_source = load_wgsl("res/shader.wgsl");
    WGPUShaderModule shader_module = wgpuDeviceCreateShaderModule(STATE_INSTANCE.device, &shader_source);

    WGPUPipelineLayout pipeline_layout = wgpuDeviceCreatePipelineLayout(STATE_INSTANCE.device, &(WGPUPipelineLayoutDescriptor){
        .label = NULL,
        .bindGroupLayoutCount = 0,
        .bindGroupLayouts = NULL,
        .nextInChain = NULL,
    });
    STATE_INSTANCE.pipeline = wgpuDeviceCreateRenderPipeline(STATE_INSTANCE.device, &(WGPURenderPipelineDescriptor) {
        .label = "pipeline",
        .layout = pipeline_layout,
        .vertex = (WGPUVertexState) {
            .module = shader_module,
            .entryPoint = "vs_main",
            .bufferCount = 1,
            .buffers = &Vertex_BUFFER_LAYOUT
        },
        .fragment = &(WGPUFragmentState) {
            .module = shader_module,
            .entryPoint = "fs_main",
            .targetCount = 1,
            .targets = &(WGPUColorTargetState) {
                .format = STATE_INSTANCE.swap_chain_format,
                .blend = &(WGPUBlendState){
                    .color = (WGPUBlendComponent) {
                        .srcFactor = WGPUBlendFactor_One,
                        .dstFactor = WGPUBlendFactor_Zero,
                        .operation = WGPUBlendOperation_Add,
                    },
                    .alpha = (WGPUBlendComponent) {
                        .srcFactor = WGPUBlendFactor_One,
                        .dstFactor = WGPUBlendFactor_Zero,
                        .operation = WGPUBlendOperation_Add,
                    }
                },
                .writeMask = WGPUColorWriteMask_All
            },
        },
        .primitive = (WGPUPrimitiveState) {
            .topology = WGPUPrimitiveTopology_TriangleList,
            .stripIndexFormat = WGPUIndexFormat_Undefined,
            .frontFace = WGPUFrontFace_CCW,
            .cullMode = WGPUCullMode_None,
        },
        .multisample = (WGPUMultisampleState) {
            .alphaToCoverageEnabled = false,
            .count = 1,
            .mask = ~0,
            .nextInChain = NULL,
        },
        .depthStencil = NULL,
    });
    VX_NULL_ASSERT(STATE_INSTANCE.pipeline);

    STATE_INSTANCE.vertex_buffer = wgpuDeviceCreateBuffer(STATE_INSTANCE.device, &(WGPUBufferDescriptor) {
        .label = "vertex_buffer",
        .usage = WGPUBufferUsage_Vertex,
        .mappedAtCreation = true,
        .size = sizeof(VERTICES)
    });
    Vertex* v_data = wgpuBufferGetMappedRange(STATE_INSTANCE.vertex_buffer, 0, sizeof(VERTICES));
    memcpy(v_data, VERTICES, sizeof(VERTICES));
    wgpuBufferUnmap(STATE_INSTANCE.vertex_buffer);

    STATE_INSTANCE.index_buffer = wgpuDeviceCreateBuffer(STATE_INSTANCE.device, &(WGPUBufferDescriptor) {
        .label = "index_buffer",
        .usage = WGPUBufferUsage_Index,
        .mappedAtCreation = true,
        .size = sizeof(INDICES)
    });
    u32* i_data = wgpuBufferGetMappedRange(STATE_INSTANCE.index_buffer, 0, sizeof(INDICES));
    memcpy(i_data, INDICES, sizeof(INDICES));
    wgpuBufferUnmap(STATE_INSTANCE.index_buffer);
}

void logic(f64 delta) {

}

void draw() {
    STATE_INSTANCE.encoder = wgpuDeviceCreateCommandEncoder(STATE_INSTANCE.device, &(WGPUCommandEncoderDescriptor){.label = "Command Encoder"});
    VX_NULL_ASSERT(STATE_INSTANCE.encoder);

    WGPUTextureView output = wgpuSwapChainGetCurrentTextureView(STATE_INSTANCE.swap_chain);
    VX_NULL_ASSERT(output);

    WGPURenderPassEncoder render_pass = wgpuCommandEncoderBeginRenderPass(STATE_INSTANCE.encoder, &(WGPURenderPassDescriptor) {
        .colorAttachments = &(WGPURenderPassColorAttachment) {
            .view = output,
            .resolveTarget = 0,
            .loadOp = WGPULoadOp_Clear,
            .storeOp = WGPUStoreOp_Store,
            .clearValue = (WGPUColor) {
                .r = 0.1,
                .g = 0.2,
                .b = 0.3,
                .a = 1.0,
            },
        },
        .colorAttachmentCount = 1,
        .depthStencilAttachment = NULL,
    });

    wgpuRenderPassEncoderSetPipeline(render_pass, STATE_INSTANCE.pipeline);
    wgpuRenderPassEncoderSetIndexBuffer(render_pass, STATE_INSTANCE.index_buffer, WGPUIndexFormat_Uint32, 0, sizeof(INDICES));
    wgpuRenderPassEncoderSetVertexBuffer(render_pass, 0, STATE_INSTANCE.vertex_buffer, 0, sizeof(VERTICES));
    //wgpuRenderPassEncoderDraw(render_pass, 3, 1, 0, 0);
    wgpuRenderPassEncoderDrawIndexed(render_pass, 6, 1, 0, 0, 0);
    wgpuRenderPassEncoderEnd(render_pass);

    WGPUCommandBuffer cmd_buffer = wgpuCommandEncoderFinish(STATE_INSTANCE.encoder, &(WGPUCommandBufferDescriptor){ .label = NULL });
    wgpuQueueSubmit(STATE_INSTANCE.queue, 1, &cmd_buffer);
    wgpuSwapChainPresent(STATE_INSTANCE.swap_chain);
}

void close() {
    wgpuBufferDestroy(STATE_INSTANCE.vertex_buffer);
}

int main() {
    initializeLog();

    vx_windowcontext_init(vx_wgpucontext_init);

    vx_WindowDescriptor desc = VX_DEFAULT(vx_WindowDescriptor);
    desc.width      = WIDTH;
    desc.height     = HEIGHT;
    desc.show_fps_in_title = true;
    desc.init_fn    = init;
    desc.logic_fn   = logic;
    desc.draw_fn    = draw;
    desc.close_fn   = close;
    vx_window_init(&desc);

    vx_window_run();
}
