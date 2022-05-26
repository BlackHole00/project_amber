#include "wgpu_utils.h"

#include <vx_utils/utils.h>

WGPUShaderModuleDescriptor load_wgsl(const char *name) {
    char* file_content = vx_filepath_get_content(name);


    WGPUShaderModuleWGSLDescriptor *wgslDescriptor = malloc(sizeof(WGPUShaderModuleWGSLDescriptor));
    wgslDescriptor->chain.next = NULL;
    wgslDescriptor->chain.sType = WGPUSType_ShaderModuleWGSLDescriptor;
    wgslDescriptor->code = (const char *)file_content;
    return (WGPUShaderModuleDescriptor){
        .nextInChain = (const WGPUChainedStruct *)wgslDescriptor,
        .label = name,
    };
}

void request_adapter_callback(WGPURequestAdapterStatus status, WGPUAdapter received, const char *message, void *userdata) {
  *(WGPUAdapter *)userdata = received;
}

void request_device_callback(WGPURequestDeviceStatus status, WGPUDevice received, const char *message, void *userdata) {
  *(WGPUDevice *)userdata = received;
}

void readBufferMap(WGPUBufferMapAsyncStatus status, void *userdata) {}

void logCallback(WGPULogLevel level, const char *msg) {
    char *level_str;
    switch (level) {
    case WGPULogLevel_Error:
        level_str = "Error";
        break;
    case WGPULogLevel_Warn:
        level_str = "Warn";
        break;
    case WGPULogLevel_Info:
        level_str = "Info";
        break;
    case WGPULogLevel_Debug:
        level_str = "Debug";
        break;
    case WGPULogLevel_Trace:
        level_str = "Trace";
        break;
    default:
        level_str = "Unknown Level";
    }
    printf("[%s] %s\n", level_str, msg);
}

void initializeLog() {
  wgpuSetLogCallback(logCallback);
  wgpuSetLogLevel(WGPULogLevel_Warn);
}