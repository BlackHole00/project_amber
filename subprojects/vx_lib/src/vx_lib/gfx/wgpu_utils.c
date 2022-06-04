#if 0

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
    switch (level) {
    case WGPULogLevel_Error:
        vx_log(VX_LOGMESSAGELEVEL_ERROR, "WGPU ERROR: %s", msg);
        break;
    case WGPULogLevel_Warn:
        vx_log(VX_LOGMESSAGELEVEL_WARN, "WGPU WARNING: %s", msg);
        break;
    case WGPULogLevel_Info:
        vx_log(VX_LOGMESSAGELEVEL_INFO, "WGPU INFO: %s", msg);
        break;
    case WGPULogLevel_Debug:
        vx_log(VX_LOGMESSAGELEVEL_INFO, "WGPU DEBUG: %s", msg);
        break;
    case WGPULogLevel_Trace:
        vx_log(VX_LOGMESSAGELEVEL_INFO, "WGPU TRACE: %s", msg);
        break;
    default:
        vx_log(VX_LOGMESSAGELEVEL_INFO, "WGPU UNKNOWN MESSAGE: %s", msg);
    }
}

void initializeLog() {
  wgpuSetLogCallback(logCallback);
  wgpuSetLogLevel(WGPULogLevel_Info);
}

#endif