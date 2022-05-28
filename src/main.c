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

const Vertex VERTICES[3] = {
    { .position = { 0.0, 0.5, 0.0 }, .color = { 1.0, 0.0, 0.0 } },
    { .position = {-0.5,-0.5, 0.0 }, .color = { 0.0, 1.0, 0.0 } },
    { .position = { 0.5,-0.5, 0.0 }, .color = { 0.0, 0.0, 1.0 } }
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
        .usage = WGPUBufferUsage_Vertex | WGPUBufferUsage_MapWrite,
        .mappedAtCreation = true,
        .size = sizeof(VERTICES)
    });
    Vertex* data = wgpuBufferGetMappedRange(STATE_INSTANCE.vertex_buffer, 0, sizeof(VERTICES));
    memcpy(data, VERTICES, sizeof(VERTICES));
    wgpuBufferUnmap(STATE_INSTANCE.vertex_buffer);

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
    wgpuRenderPassEncoderSetVertexBuffer(render_pass, 0, STATE_INSTANCE.vertex_buffer, 0, sizeof(VERTICES));
    wgpuRenderPassEncoderDraw(render_pass, 3, 1, 0, 0);
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

#if 0
#include <webgpu.h>
#include <wgpu.h>

#include "framework.h"
#include <stdio.h>
#include <stdlib.h>

#define WGPU_TARGET_MACOS 1
#define WGPU_TARGET_LINUX_X11 2
#define WGPU_TARGET_WINDOWS 3
#define WGPU_TARGET_LINUX_WAYLAND 4

#define WGPU_TARGET WGPU_TARGET_WINDOWS

#if WGPU_TARGET == WGPU_TARGET_MACOS
#include <Foundation/Foundation.h>
#include <QuartzCore/CAMetalLayer.h>
#endif

#include <GLFW/glfw3.h>
#if WGPU_TARGET == WGPU_TARGET_MACOS
#define GLFW_EXPOSE_NATIVE_COCOA
#elif WGPU_TARGET == WGPU_TARGET_LINUX_X11
#define GLFW_EXPOSE_NATIVE_X11
#elif WGPU_TARGET == WGPU_TARGET_LINUX_WAYLAND
#define GLFW_EXPOSE_NATIVE_WAYLAND
#elif WGPU_TARGET == WGPU_TARGET_WINDOWS
#define GLFW_EXPOSE_NATIVE_WIN32
#endif
#include <GLFW/glfw3native.h>

static void handle_device_lost(WGPUDeviceLostReason reason, char const * message, void * userdata)
{
  printf("DEVICE LOST (%d): %s\n", reason, message);
}

static void handle_uncaptured_error(WGPUErrorType type, char const * message, void * userdata)
{
  printf("UNCAPTURED ERROR (%d): %s\n", type, message);
}

int main() {
  initializeLog();

  if (!glfwInit()) {
    printf("Cannot initialize glfw");
    return 1;
  }

  glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
  GLFWwindow *window = glfwCreateWindow(640, 480, "wgpu with glfw", NULL, NULL);

  if (!window) {
    printf("Cannot create window");
    return 1;
  }

  WGPUSurface surface;

#if WGPU_TARGET == WGPU_TARGET_MACOS
  {
    id metal_layer = NULL;
    NSWindow *ns_window = glfwGetCocoaWindow(window);
    [ns_window.contentView setWantsLayer:YES];
    metal_layer = [CAMetalLayer layer];
    [ns_window.contentView setLayer:metal_layer];
    surface = wgpuInstanceCreateSurface(
        NULL,
        &(WGPUSurfaceDescriptor){
            .label = NULL,
            .nextInChain =
                (const WGPUChainedStruct *)&(
                    WGPUSurfaceDescriptorFromMetalLayer){
                    .chain =
                        (WGPUChainedStruct){
                            .next = NULL,
                            .sType = WGPUSType_SurfaceDescriptorFromMetalLayer,
                        },
                    .layer = metal_layer,
                },
        });
  }
#elif WGPU_TARGET == WGPU_TARGET_LINUX_X11
  {
    Display *x11_display = glfwGetX11Display();
    Window x11_window = glfwGetX11Window(window);
    surface = wgpuInstanceCreateSurface(
        NULL,
        &(WGPUSurfaceDescriptor){
            .label = NULL,
            .nextInChain =
                (const WGPUChainedStruct *)&(WGPUSurfaceDescriptorFromXlibWindow){
                    .chain =
                        (WGPUChainedStruct){
                            .next = NULL,
                            .sType = WGPUSType_SurfaceDescriptorFromXlibWindow,
                        },
                    .display = x11_display,
                    .window = x11_window,
                },
        });
  }
#elif WGPU_TARGET == WGPU_TARGET_LINUX_WAYLAND
  {
    struct wl_display *wayland_display = glfwGetWaylandDisplay();
    struct wl_surface *wayland_surface = glfwGetWaylandWindow(window);
    surface = wgpuInstanceCreateSurface(
        NULL,
        &(WGPUSurfaceDescriptor){
            .label = NULL,
            .nextInChain =
                (const WGPUChainedStruct *)&(
                    WGPUSurfaceDescriptorFromWaylandSurface){
                    .chain =
                        (WGPUChainedStruct){
                            .next = NULL,
                            .sType =
                                WGPUSType_SurfaceDescriptorFromWaylandSurface,
                        },
                    .display = wayland_display,
                    .surface = wayland_surface,
                },
        });
  }
#elif WGPU_TARGET == WGPU_TARGET_WINDOWS
  {
    HWND hwnd = glfwGetWin32Window(window);
    HINSTANCE hinstance = GetModuleHandle(NULL);
    surface = wgpuInstanceCreateSurface(
        NULL,
        &(WGPUSurfaceDescriptor){
            .label = NULL,
            .nextInChain =
                (const WGPUChainedStruct *)&(
                    WGPUSurfaceDescriptorFromWindowsHWND){
                    .chain =
                        (WGPUChainedStruct){
                            .next = NULL,
                            .sType = WGPUSType_SurfaceDescriptorFromWindowsHWND,
                        },
                    .hinstance = hinstance,
                    .hwnd = hwnd,
                },
        });
  }
#else
#error "Unsupported WGPU_TARGET"
#endif

  WGPUAdapter adapter;
  wgpuInstanceRequestAdapter(NULL,
                             &(WGPURequestAdapterOptions){
                                 .nextInChain = NULL,
                                 .compatibleSurface = surface,
                             },
                             request_adapter_callback, (void *)&adapter);

  WGPUDevice device;
  wgpuAdapterRequestDevice(
      adapter,
      &(WGPUDeviceDescriptor){
          .nextInChain =
              (const WGPUChainedStruct *)&(WGPUDeviceExtras){
                  .chain =
                      (WGPUChainedStruct){
                          .next = NULL,
                          .sType = WGPUSType_DeviceExtras,
                      },
                  .label = "Device",
                  .tracePath = NULL,
              },
          .requiredLimits =
              &(WGPURequiredLimits){
                  .nextInChain = NULL,
                  .limits =
                      (WGPULimits){
                          .maxBindGroups = 1,
                      },
              },
      },
      request_device_callback, (void *)&device);

  wgpuDeviceSetUncapturedErrorCallback(device, handle_uncaptured_error, NULL);
  wgpuDeviceSetDeviceLostCallback(device, handle_device_lost, NULL);

  WGPUShaderModuleDescriptor shaderSource = load_wgsl("res/shader.wgsl");
  WGPUShaderModule shader = wgpuDeviceCreateShaderModule(device, &shaderSource);

  WGPUPipelineLayout pipelineLayout = wgpuDeviceCreatePipelineLayout(
      device, &(WGPUPipelineLayoutDescriptor){.bindGroupLayouts = NULL,
                                              .bindGroupLayoutCount = 0});

  WGPUTextureFormat swapChainFormat =
      wgpuSurfaceGetPreferredFormat(surface, adapter);

  WGPURenderPipeline pipeline = wgpuDeviceCreateRenderPipeline(
      device,
      &(WGPURenderPipelineDescriptor){
          .label = "Render pipeline",
          .layout = pipelineLayout,
          .vertex =
              (WGPUVertexState){
                  .module = shader,
                  .entryPoint = "vs_main",
                  .bufferCount = 0,
                  .buffers = NULL,
              },
          .primitive =
              (WGPUPrimitiveState){
                  .topology = WGPUPrimitiveTopology_TriangleList,
                  .stripIndexFormat = WGPUIndexFormat_Undefined,
                  .frontFace = WGPUFrontFace_CCW,
                  .cullMode = WGPUCullMode_None},
          .multisample =
              (WGPUMultisampleState){
                  .count = 1,
                  .mask = ~0,
                  .alphaToCoverageEnabled = false,
              },
          .fragment =
              &(WGPUFragmentState){
                  .module = shader,
                  .entryPoint = "fs_main",
                  .targetCount = 1,
                  .targets =
                      &(WGPUColorTargetState){
                          .format = swapChainFormat,
                          .blend =
                              &(WGPUBlendState){
                                  .color =
                                      (WGPUBlendComponent){
                                          .srcFactor = WGPUBlendFactor_One,
                                          .dstFactor = WGPUBlendFactor_Zero,
                                          .operation = WGPUBlendOperation_Add,
                                      },
                                  .alpha =
                                      (WGPUBlendComponent){
                                          .srcFactor = WGPUBlendFactor_One,
                                          .dstFactor = WGPUBlendFactor_Zero,
                                          .operation = WGPUBlendOperation_Add,
                                      }},
                          .writeMask = WGPUColorWriteMask_All},
              },
          .depthStencil = NULL,
      });

  int prevWidth = 0;
  int prevHeight = 0;
  glfwGetWindowSize(window, &prevWidth, &prevHeight);

  WGPUSwapChain swapChain =
      wgpuDeviceCreateSwapChain(device, surface,
                                &(WGPUSwapChainDescriptor){
                                    .usage = WGPUTextureUsage_RenderAttachment,
                                    .format = swapChainFormat,
                                    .width = prevWidth,
                                    .height = prevHeight,
                                    .presentMode = WGPUPresentMode_Fifo,
                                });

  while (!glfwWindowShouldClose(window)) {

    WGPUTextureView nextTexture = NULL;

    for (int attempt = 0; attempt < 2; attempt++) {

      int width = 0;
      int height = 0;
      glfwGetWindowSize(window, &width, &height);

      if (width != prevWidth || height != prevHeight) {
        prevWidth = width;
        prevHeight = height;

        swapChain = wgpuDeviceCreateSwapChain(
            device, surface,
            &(WGPUSwapChainDescriptor){
                .usage = WGPUTextureUsage_RenderAttachment,
                .format = swapChainFormat,
                .width = prevWidth,
                .height = prevHeight,
                .presentMode = WGPUPresentMode_Fifo,
            });
      }

      nextTexture = wgpuSwapChainGetCurrentTextureView(swapChain);

      if (attempt == 0 && !nextTexture) {
        printf("wgpuSwapChainGetCurrentTextureView() failed; trying to create a new swap chain...\n");
        prevWidth = 0;
        prevHeight = 0;
        continue;
      }

      break;
    }

    if (!nextTexture) {
      printf("Cannot acquire next swap chain texture\n");
      return 1;
    }

    WGPUCommandEncoder encoder = wgpuDeviceCreateCommandEncoder(
        device, &(WGPUCommandEncoderDescriptor){.label = "Command Encoder"});

    WGPURenderPassEncoder renderPass = wgpuCommandEncoderBeginRenderPass(
        encoder, &(WGPURenderPassDescriptor){
                     .colorAttachments =
                         &(WGPURenderPassColorAttachment){
                             .view = nextTexture,
                             .resolveTarget = 0,
                             .loadOp = WGPULoadOp_Clear,
                             .storeOp = WGPUStoreOp_Store,
                             .clearValue =
                                 (WGPUColor){
                                     .r = 0.0,
                                     .g = 1.0,
                                     .b = 0.0,
                                     .a = 1.0,
                                 },
                         },
                     .colorAttachmentCount = 1,
                     .depthStencilAttachment = NULL,
                 });

    wgpuRenderPassEncoderSetPipeline(renderPass, pipeline);
    wgpuRenderPassEncoderDraw(renderPass, 3, 1, 0, 0);
    wgpuRenderPassEncoderEnd(renderPass);

    WGPUQueue queue = wgpuDeviceGetQueue(device);
    WGPUCommandBuffer cmdBuffer = wgpuCommandEncoderFinish(
        encoder, &(WGPUCommandBufferDescriptor){.label = NULL});
    wgpuQueueSubmit(queue, 1, &cmdBuffer);
    wgpuSwapChainPresent(swapChain);

    glfwPollEvents();
  }

  glfwDestroyWindow(window);
  glfwTerminate();

  return 0;
}

#endif