package wgpu

foreign import "wgpu_native.lib"

import _c "core:c"

WGPU_ARRAY_LAYER_COUNT_UNDEFINED :: 4294967295
WGPU_COPY_STRIDE_UNDEFINED :: 4294967295
WGPU_LIMIT_U32_UNDEFINED :: 4294967295
WGPU_LIMIT_U64_UNDEFINED :: -1
WGPU_MIP_LEVEL_COUNT_UNDEFINED :: 4294967295
WGPU_WHOLE_SIZE :: -1

Flags :: u32
Adapter :: ^AdapterImpl
BindGroup :: ^BindGroupImpl
BindGroupLayout :: ^BindGroupLayoutImpl
Buffer :: ^BufferImpl
CommandBuffer :: ^CommandBufferImpl
CommandEncoder :: ^CommandEncoderImpl
ComputePassEncoder :: ^ComputePassEncoderImpl
ComputePipeline :: ^ComputePipelineImpl
Device :: ^DeviceImpl
Instance :: ^InstanceImpl
PipelineLayout :: ^PipelineLayoutImpl
QuerySet :: ^QuerySetImpl
Queue :: ^QueueImpl
RenderBundle :: ^RenderBundleImpl
RenderBundleEncoder :: ^RenderBundleEncoderImpl
RenderPassEncoder :: ^RenderPassEncoderImpl
RenderPipeline :: ^RenderPipelineImpl
Sampler :: ^SamplerImpl
ShaderModule :: ^ShaderModuleImpl
Surface :: ^SurfaceImpl
SwapChain :: ^SwapChainImpl
Texture :: ^TextureImpl
TextureView :: ^TextureViewImpl
BufferUsageFlags :: u32
ColorWriteMaskFlags :: u32
MapModeFlags :: u32
ShaderStageFlags :: u32
TextureUsageFlags :: u32
BufferMapCallback :: #type proc(status : BufferMapAsyncStatus, userdata : rawptr)
CompilationInfoCallback :: #type proc(status : CompilationInfoRequestStatus, compilation_info : ^CompilationInfo, userdata : rawptr)
CreateComputePipelineAsyncCallback :: #type proc(status : CreatePipelineAsyncStatus, pipeline : ComputePipeline, message : cstring, userdata : rawptr)
CreateRenderPipelineAsyncCallback :: #type proc(status : CreatePipelineAsyncStatus, pipeline : RenderPipeline, message : cstring, userdata : rawptr)
DeviceLostCallback :: #type proc(reason : DeviceLostReason, message : cstring, userdata : rawptr)
ErrorCallback :: #type proc(type : ErrorType, message : cstring, userdata : rawptr)
Proc :: #type proc()
QueueWorkDoneCallback :: #type proc(status : QueueWorkDoneStatus, userdata : rawptr)
RequestAdapterCallback :: #type proc(status : RequestAdapterStatus, adapter : Adapter, message : cstring, userdata : rawptr)
RequestDeviceCallback :: #type proc(status : RequestDeviceStatus, device : Device, message : cstring, userdata : rawptr)
ProcCreateInstance :: #type proc(descriptor : ^InstanceDescriptor) -> Instance
ProcGetProcAddress :: #type proc(device : Device, proc_name : cstring) -> Proc
ProcAdapterEnumerateFeatures :: #type proc(adapter : Adapter, features : ^FeatureName) -> _c.size_t
ProcAdapterGetLimits :: #type proc(adapter : Adapter, limits : ^SupportedLimits) -> Bool
ProcAdapterGetProperties :: #type proc(adapter : Adapter, properties : ^AdapterProperties)
ProcAdapterHasFeature :: #type proc(adapter : Adapter, feature : FeatureName) -> Bool
ProcAdapterRequestDevice :: #type proc(adapter : Adapter, descriptor : ^DeviceDescriptor, callback : RequestDeviceCallback, userdata : rawptr)
ProcBindGroupSetLabel :: #type proc(bind_group : BindGroup, label : cstring)
ProcBindGroupLayoutSetLabel :: #type proc(bind_group_layout : BindGroupLayout, label : cstring)
ProcBufferDestroy :: #type proc(buffer : Buffer)
ProcBufferGetConstMappedRange :: #type proc(buffer : Buffer, offset : _c.size_t, size : _c.size_t) -> rawptr
ProcBufferGetMappedRange :: #type proc(buffer : Buffer, offset : _c.size_t, size : _c.size_t) -> rawptr
ProcBufferMapAsync :: #type proc(buffer : Buffer, mode : u32, offset : _c.size_t, size : _c.size_t, callback : BufferMapCallback, userdata : rawptr)
ProcBufferSetLabel :: #type proc(buffer : Buffer, label : cstring)
ProcBufferUnmap :: #type proc(buffer : Buffer)
ProcCommandBufferSetLabel :: #type proc(command_buffer : CommandBuffer, label : cstring)
ProcCommandEncoderBeginComputePass :: #type proc(command_encoder : CommandEncoder, descriptor : ^ComputePassDescriptor) -> ComputePassEncoder
ProcCommandEncoderBeginRenderPass :: #type proc(command_encoder : CommandEncoder, descriptor : ^RenderPassDescriptor) -> RenderPassEncoder
ProcCommandEncoderClearBuffer :: #type proc(command_encoder : CommandEncoder, buffer : Buffer, offset : u64, size : u64)
ProcCommandEncoderCopyBufferToBuffer :: #type proc(command_encoder : CommandEncoder, source : Buffer, source_offset : u64, destination : Buffer, destination_offset : u64, size : u64)
ProcCommandEncoderCopyBufferToTexture :: #type proc(command_encoder : CommandEncoder, source : ^ImageCopyBuffer, destination : ^ImageCopyTexture, copy_size : ^Extent3D)
ProcCommandEncoderCopyTextureToBuffer :: #type proc(command_encoder : CommandEncoder, source : ^ImageCopyTexture, destination : ^ImageCopyBuffer, copy_size : ^Extent3D)
ProcCommandEncoderCopyTextureToTexture :: #type proc(command_encoder : CommandEncoder, source : ^ImageCopyTexture, destination : ^ImageCopyTexture, copy_size : ^Extent3D)
ProcCommandEncoderFinish :: #type proc(command_encoder : CommandEncoder, descriptor : ^CommandBufferDescriptor) -> CommandBuffer
ProcCommandEncoderInsertDebugMarker :: #type proc(command_encoder : CommandEncoder, marker_label : cstring)
ProcCommandEncoderPopDebugGroup :: #type proc(command_encoder : CommandEncoder)
ProcCommandEncoderPushDebugGroup :: #type proc(command_encoder : CommandEncoder, group_label : cstring)
ProcCommandEncoderResolveQuerySet :: #type proc(command_encoder : CommandEncoder, query_set : QuerySet, first_query : u32, query_count : u32, destination : Buffer, destination_offset : u64)
ProcCommandEncoderSetLabel :: #type proc(command_encoder : CommandEncoder, label : cstring)
ProcCommandEncoderWriteTimestamp :: #type proc(command_encoder : CommandEncoder, query_set : QuerySet, query_index : u32)
ProcComputePassEncoderBeginPipelineStatisticsQuery :: #type proc(compute_pass_encoder : ComputePassEncoder, query_set : QuerySet, query_index : u32)
ProcComputePassEncoderDispatchWorkgroups :: #type proc(compute_pass_encoder : ComputePassEncoder, workgroup_count_x : u32, workgroup_count_y : u32, workgroup_count_z : u32)
ProcComputePassEncoderDispatchWorkgroupsIndirect :: #type proc(compute_pass_encoder : ComputePassEncoder, indirect_buffer : Buffer, indirect_offset : u64)
ProcComputePassEncoderEnd :: #type proc(compute_pass_encoder : ComputePassEncoder)
ProcComputePassEncoderEndPipelineStatisticsQuery :: #type proc(compute_pass_encoder : ComputePassEncoder)
ProcComputePassEncoderInsertDebugMarker :: #type proc(compute_pass_encoder : ComputePassEncoder, marker_label : cstring)
ProcComputePassEncoderPopDebugGroup :: #type proc(compute_pass_encoder : ComputePassEncoder)
ProcComputePassEncoderPushDebugGroup :: #type proc(compute_pass_encoder : ComputePassEncoder, group_label : cstring)
ProcComputePassEncoderSetBindGroup :: #type proc(compute_pass_encoder : ComputePassEncoder, group_index : u32, group : BindGroup, dynamic_offset_count : u32, dynamic_offsets : ^u32)
ProcComputePassEncoderSetLabel :: #type proc(compute_pass_encoder : ComputePassEncoder, label : cstring)
ProcComputePassEncoderSetPipeline :: #type proc(compute_pass_encoder : ComputePassEncoder, pipeline : ComputePipeline)
ProcComputePipelineGetBindGroupLayout :: #type proc(compute_pipeline : ComputePipeline, group_index : u32) -> BindGroupLayout
ProcComputePipelineSetLabel :: #type proc(compute_pipeline : ComputePipeline, label : cstring)
ProcDeviceCreateBindGroup :: #type proc(device : Device, descriptor : ^BindGroupDescriptor) -> BindGroup
ProcDeviceCreateBindGroupLayout :: #type proc(device : Device, descriptor : ^BindGroupLayoutDescriptor) -> BindGroupLayout
ProcDeviceCreateBuffer :: #type proc(device : Device, descriptor : ^BufferDescriptor) -> Buffer
ProcDeviceCreateCommandEncoder :: #type proc(device : Device, descriptor : ^CommandEncoderDescriptor) -> CommandEncoder
ProcDeviceCreateComputePipeline :: #type proc(device : Device, descriptor : ^ComputePipelineDescriptor) -> ComputePipeline
ProcDeviceCreateComputePipelineAsync :: #type proc(device : Device, descriptor : ^ComputePipelineDescriptor, callback : CreateComputePipelineAsyncCallback, userdata : rawptr)
ProcDeviceCreatePipelineLayout :: #type proc(device : Device, descriptor : ^PipelineLayoutDescriptor) -> PipelineLayout
ProcDeviceCreateQuerySet :: #type proc(device : Device, descriptor : ^QuerySetDescriptor) -> QuerySet
ProcDeviceCreateRenderBundleEncoder :: #type proc(device : Device, descriptor : ^RenderBundleEncoderDescriptor) -> RenderBundleEncoder
ProcDeviceCreateRenderPipeline :: #type proc(device : Device, descriptor : ^RenderPipelineDescriptor) -> RenderPipeline
ProcDeviceCreateRenderPipelineAsync :: #type proc(device : Device, descriptor : ^RenderPipelineDescriptor, callback : CreateRenderPipelineAsyncCallback, userdata : rawptr)
ProcDeviceCreateSampler :: #type proc(device : Device, descriptor : ^SamplerDescriptor) -> Sampler
ProcDeviceCreateShaderModule :: #type proc(device : Device, descriptor : ^ShaderModuleDescriptor) -> ShaderModule
ProcDeviceCreateSwapChain :: #type proc(device : Device, surface : Surface, descriptor : ^SwapChainDescriptor) -> SwapChain
ProcDeviceCreateTexture :: #type proc(device : Device, descriptor : ^TextureDescriptor) -> Texture
ProcDeviceDestroy :: #type proc(device : Device)
ProcDeviceEnumerateFeatures :: #type proc(device : Device, features : ^FeatureName) -> _c.size_t
ProcDeviceGetLimits :: #type proc(device : Device, limits : ^SupportedLimits) -> Bool
ProcDeviceGetQueue :: #type proc(device : Device) -> Queue
ProcDeviceHasFeature :: #type proc(device : Device, feature : FeatureName) -> Bool
ProcDevicePopErrorScope :: #type proc(device : Device, callback : ErrorCallback, userdata : rawptr) -> Bool
ProcDevicePushErrorScope :: #type proc(device : Device, filter : ErrorFilter)
ProcDeviceSetDeviceLostCallback :: #type proc(device : Device, callback : DeviceLostCallback, userdata : rawptr)
ProcDeviceSetLabel :: #type proc(device : Device, label : cstring)
ProcDeviceSetUncapturedErrorCallback :: #type proc(device : Device, callback : ErrorCallback, userdata : rawptr)
ProcInstanceCreateSurface :: #type proc(instance : Instance, descriptor : ^SurfaceDescriptor) -> Surface
ProcInstanceProcessEvents :: #type proc(instance : Instance)
ProcInstanceRequestAdapter :: #type proc(instance : Instance, options : ^RequestAdapterOptions, callback : RequestAdapterCallback, userdata : rawptr)
ProcPipelineLayoutSetLabel :: #type proc(pipeline_layout : PipelineLayout, label : cstring)
ProcQuerySetDestroy :: #type proc(query_set : QuerySet)
ProcQuerySetSetLabel :: #type proc(query_set : QuerySet, label : cstring)
ProcQueueOnSubmittedWorkDone :: #type proc(queue : Queue, callback : QueueWorkDoneCallback, userdata : rawptr)
ProcQueueSetLabel :: #type proc(queue : Queue, label : cstring)
ProcQueueSubmit :: #type proc(queue : Queue, command_count : u32, commands : ^CommandBuffer)
ProcQueueWriteBuffer :: #type proc(queue : Queue, buffer : Buffer, buffer_offset : u64, data : rawptr, size : _c.size_t)
ProcQueueWriteTexture :: #type proc(queue : Queue, destination : ^ImageCopyTexture, data : rawptr, data_size : _c.size_t, data_layout : ^TextureDataLayout, write_size : ^Extent3D)
ProcRenderBundleEncoderDraw :: #type proc(render_bundle_encoder : RenderBundleEncoder, vertex_count : u32, instance_count : u32, first_vertex : u32, first_instance : u32)
ProcRenderBundleEncoderDrawIndexed :: #type proc(render_bundle_encoder : RenderBundleEncoder, index_count : u32, instance_count : u32, first_index : u32, base_vertex : i32, first_instance : u32)
ProcRenderBundleEncoderDrawIndexedIndirect :: #type proc(render_bundle_encoder : RenderBundleEncoder, indirect_buffer : Buffer, indirect_offset : u64)
ProcRenderBundleEncoderDrawIndirect :: #type proc(render_bundle_encoder : RenderBundleEncoder, indirect_buffer : Buffer, indirect_offset : u64)
ProcRenderBundleEncoderFinish :: #type proc(render_bundle_encoder : RenderBundleEncoder, descriptor : ^RenderBundleDescriptor) -> RenderBundle
ProcRenderBundleEncoderInsertDebugMarker :: #type proc(render_bundle_encoder : RenderBundleEncoder, marker_label : cstring)
ProcRenderBundleEncoderPopDebugGroup :: #type proc(render_bundle_encoder : RenderBundleEncoder)
ProcRenderBundleEncoderPushDebugGroup :: #type proc(render_bundle_encoder : RenderBundleEncoder, group_label : cstring)
ProcRenderBundleEncoderSetBindGroup :: #type proc(render_bundle_encoder : RenderBundleEncoder, group_index : u32, group : BindGroup, dynamic_offset_count : u32, dynamic_offsets : ^u32)
ProcRenderBundleEncoderSetIndexBuffer :: #type proc(render_bundle_encoder : RenderBundleEncoder, buffer : Buffer, format : IndexFormat, offset : u64, size : u64)
ProcRenderBundleEncoderSetLabel :: #type proc(render_bundle_encoder : RenderBundleEncoder, label : cstring)
ProcRenderBundleEncoderSetPipeline :: #type proc(render_bundle_encoder : RenderBundleEncoder, pipeline : RenderPipeline)
ProcRenderBundleEncoderSetVertexBuffer :: #type proc(render_bundle_encoder : RenderBundleEncoder, slot : u32, buffer : Buffer, offset : u64, size : u64)
ProcRenderPassEncoderBeginOcclusionQuery :: #type proc(render_pass_encoder : RenderPassEncoder, query_index : u32)
ProcRenderPassEncoderBeginPipelineStatisticsQuery :: #type proc(render_pass_encoder : RenderPassEncoder, query_set : QuerySet, query_index : u32)
ProcRenderPassEncoderDraw :: #type proc(render_pass_encoder : RenderPassEncoder, vertex_count : u32, instance_count : u32, first_vertex : u32, first_instance : u32)
ProcRenderPassEncoderDrawIndexed :: #type proc(render_pass_encoder : RenderPassEncoder, index_count : u32, instance_count : u32, first_index : u32, base_vertex : i32, first_instance : u32)
ProcRenderPassEncoderDrawIndexedIndirect :: #type proc(render_pass_encoder : RenderPassEncoder, indirect_buffer : Buffer, indirect_offset : u64)
ProcRenderPassEncoderDrawIndirect :: #type proc(render_pass_encoder : RenderPassEncoder, indirect_buffer : Buffer, indirect_offset : u64)
ProcRenderPassEncoderEnd :: #type proc(render_pass_encoder : RenderPassEncoder)
ProcRenderPassEncoderEndOcclusionQuery :: #type proc(render_pass_encoder : RenderPassEncoder)
ProcRenderPassEncoderEndPipelineStatisticsQuery :: #type proc(render_pass_encoder : RenderPassEncoder)
ProcRenderPassEncoderExecuteBundles :: #type proc(render_pass_encoder : RenderPassEncoder, bundles_count : u32, bundles : ^RenderBundle)
ProcRenderPassEncoderInsertDebugMarker :: #type proc(render_pass_encoder : RenderPassEncoder, marker_label : cstring)
ProcRenderPassEncoderPopDebugGroup :: #type proc(render_pass_encoder : RenderPassEncoder)
ProcRenderPassEncoderPushDebugGroup :: #type proc(render_pass_encoder : RenderPassEncoder, group_label : cstring)
ProcRenderPassEncoderSetBindGroup :: #type proc(render_pass_encoder : RenderPassEncoder, group_index : u32, group : BindGroup, dynamic_offset_count : u32, dynamic_offsets : ^u32)
ProcRenderPassEncoderSetBlendConstant :: #type proc(render_pass_encoder : RenderPassEncoder, color : ^Color)
ProcRenderPassEncoderSetIndexBuffer :: #type proc(render_pass_encoder : RenderPassEncoder, buffer : Buffer, format : IndexFormat, offset : u64, size : u64)
ProcRenderPassEncoderSetLabel :: #type proc(render_pass_encoder : RenderPassEncoder, label : cstring)
ProcRenderPassEncoderSetPipeline :: #type proc(render_pass_encoder : RenderPassEncoder, pipeline : RenderPipeline)
ProcRenderPassEncoderSetScissorRect :: #type proc(render_pass_encoder : RenderPassEncoder, x : u32, y : u32, width : u32, height : u32)
ProcRenderPassEncoderSetStencilReference :: #type proc(render_pass_encoder : RenderPassEncoder, reference : u32)
ProcRenderPassEncoderSetVertexBuffer :: #type proc(render_pass_encoder : RenderPassEncoder, slot : u32, buffer : Buffer, offset : u64, size : u64)
ProcRenderPassEncoderSetViewport :: #type proc(render_pass_encoder : RenderPassEncoder, x : _c.float, y : _c.float, width : _c.float, height : _c.float, min_depth : _c.float, max_depth : _c.float)
ProcRenderPipelineGetBindGroupLayout :: #type proc(render_pipeline : RenderPipeline, group_index : u32) -> BindGroupLayout
ProcRenderPipelineSetLabel :: #type proc(render_pipeline : RenderPipeline, label : cstring)
ProcSamplerSetLabel :: #type proc(sampler : Sampler, label : cstring)
ProcShaderModuleGetCompilationInfo :: #type proc(shader_module : ShaderModule, callback : CompilationInfoCallback, userdata : rawptr)
ProcShaderModuleSetLabel :: #type proc(shader_module : ShaderModule, label : cstring)
ProcSurfaceGetPreferredFormat :: #type proc(surface : Surface, adapter : Adapter) -> TextureFormat
ProcSwapChainGetCurrentTextureView :: #type proc(swap_chain : SwapChain) -> TextureView
ProcSwapChainPresent :: #type proc(swap_chain : SwapChain)
ProcTextureCreateView :: #type proc(texture : Texture, descriptor : ^TextureViewDescriptor) -> TextureView
ProcTextureDestroy :: #type proc(texture : Texture)
ProcTextureSetLabel :: #type proc(texture : Texture, label : cstring)
ProcTextureViewSetLabel :: #type proc(texture_view : TextureView, label : cstring)

AdapterType :: enum i32 {
    AdaptertypeDiscretegpu = 0,
    AdaptertypeIntegratedgpu = 1,
    AdaptertypeCpu = 2,
    AdaptertypeUnknown = 3,
    AdaptertypeForce32 = 2147483647,
}

AddressMode :: enum i32 {
    AddressmodeRepeat = 0,
    AddressmodeMirrorrepeat = 1,
    AddressmodeClamptoedge = 2,
    AddressmodeForce32 = 2147483647,
}

BackendType :: enum i32 {
    BackendtypeNull = 0,
    BackendtypeWebgpu = 1,
    BackendtypeD3D11 = 2,
    BackendtypeD3D12 = 3,
    BackendtypeMetal = 4,
    BackendtypeVulkan = 5,
    BackendtypeOpengl = 6,
    BackendtypeOpengles = 7,
    BackendtypeForce32 = 2147483647,
}

BlendFactor :: enum i32 {
    BlendfactorZero = 0,
    BlendfactorOne = 1,
    BlendfactorSrc = 2,
    BlendfactorOneminussrc = 3,
    BlendfactorSrcalpha = 4,
    BlendfactorOneminussrcalpha = 5,
    BlendfactorDst = 6,
    BlendfactorOneminusdst = 7,
    BlendfactorDstalpha = 8,
    BlendfactorOneminusdstalpha = 9,
    BlendfactorSrcalphasaturated = 10,
    BlendfactorConstant = 11,
    BlendfactorOneminusconstant = 12,
    BlendfactorForce32 = 2147483647,
}

BlendOperation :: enum i32 {
    BlendoperationAdd = 0,
    BlendoperationSubtract = 1,
    BlendoperationReversesubtract = 2,
    BlendoperationMin = 3,
    BlendoperationMax = 4,
    BlendoperationForce32 = 2147483647,
}

BufferBindingType :: enum i32 {
    BufferbindingtypeUndefined = 0,
    BufferbindingtypeUniform = 1,
    BufferbindingtypeStorage = 2,
    BufferbindingtypeReadonlystorage = 3,
    BufferbindingtypeForce32 = 2147483647,
}

BufferMapAsyncStatus :: enum i32 {
    BuffermapasyncstatusSuccess = 0,
    BuffermapasyncstatusError = 1,
    BuffermapasyncstatusUnknown = 2,
    BuffermapasyncstatusDevicelost = 3,
    BuffermapasyncstatusDestroyedbeforecallback = 4,
    BuffermapasyncstatusUnmappedbeforecallback = 5,
    BuffermapasyncstatusForce32 = 2147483647,
}

CompareFunction :: enum i32 {
    ComparefunctionUndefined = 0,
    ComparefunctionNever = 1,
    ComparefunctionLess = 2,
    ComparefunctionLessequal = 3,
    ComparefunctionGreater = 4,
    ComparefunctionGreaterequal = 5,
    ComparefunctionEqual = 6,
    ComparefunctionNotequal = 7,
    ComparefunctionAlways = 8,
    ComparefunctionForce32 = 2147483647,
}

CompilationInfoRequestStatus :: enum i32 {
    CompilationinforequeststatusSuccess = 0,
    CompilationinforequeststatusError = 1,
    CompilationinforequeststatusDevicelost = 2,
    CompilationinforequeststatusUnknown = 3,
    CompilationinforequeststatusForce32 = 2147483647,
}

CompilationMessageType :: enum i32 {
    CompilationmessagetypeError = 0,
    CompilationmessagetypeWarning = 1,
    CompilationmessagetypeInfo = 2,
    CompilationmessagetypeForce32 = 2147483647,
}

ComputePassTimestampLocation :: enum i32 {
    ComputepasstimestamplocationBeginning = 0,
    ComputepasstimestamplocationEnd = 1,
    ComputepasstimestamplocationForce32 = 2147483647,
}

CreatePipelineAsyncStatus :: enum i32 {
    CreatepipelineasyncstatusSuccess = 0,
    CreatepipelineasyncstatusError = 1,
    CreatepipelineasyncstatusDevicelost = 2,
    CreatepipelineasyncstatusDevicedestroyed = 3,
    CreatepipelineasyncstatusUnknown = 4,
    CreatepipelineasyncstatusForce32 = 2147483647,
}

CullMode :: enum i32 {
    CullmodeNone = 0,
    CullmodeFront = 1,
    CullmodeBack = 2,
    CullmodeForce32 = 2147483647,
}

DeviceLostReason :: enum i32 {
    DevicelostreasonUndefined = 0,
    DevicelostreasonDestroyed = 1,
    DevicelostreasonForce32 = 2147483647,
}

ErrorFilter :: enum i32 {
    ErrorfilterValidation = 0,
    ErrorfilterOutofmemory = 1,
    ErrorfilterForce32 = 2147483647,
}

ErrorType :: enum i32 {
    ErrortypeNoerror = 0,
    ErrortypeValidation = 1,
    ErrortypeOutofmemory = 2,
    ErrortypeUnknown = 3,
    ErrortypeDevicelost = 4,
    ErrortypeForce32 = 2147483647,
}

FeatureName :: enum i32 {
    FeaturenameUndefined = 0,
    FeaturenameDepthclipcontrol = 1,
    FeaturenameDepth24Unormstencil8 = 2,
    FeaturenameDepth32Floatstencil8 = 3,
    FeaturenameTimestampquery = 4,
    FeaturenamePipelinestatisticsquery = 5,
    FeaturenameTexturecompressionbc = 6,
    FeaturenameTexturecompressionetc2 = 7,
    FeaturenameTexturecompressionastc = 8,
    FeaturenameIndirectfirstinstance = 9,
    FeaturenameForce32 = 2147483647,
}

FilterMode :: enum i32 {
    FiltermodeNearest = 0,
    FiltermodeLinear = 1,
    FiltermodeForce32 = 2147483647,
}

FrontFace :: enum i32 {
    FrontfaceCcw = 0,
    FrontfaceCw = 1,
    FrontfaceForce32 = 2147483647,
}

IndexFormat :: enum i32 {
    IndexformatUndefined = 0,
    IndexformatUint16 = 1,
    IndexformatUint32 = 2,
    IndexformatForce32 = 2147483647,
}

LoadOp :: enum i32 {
    LoadopUndefined = 0,
    LoadopClear = 1,
    LoadopLoad = 2,
    LoadopForce32 = 2147483647,
}

MipmapFilterMode :: enum i32 {
    MipmapfiltermodeNearest = 0,
    MipmapfiltermodeLinear = 1,
    MipmapfiltermodeForce32 = 2147483647,
}

PipelineStatisticName :: enum i32 {
    PipelinestatisticnameVertexshaderinvocations = 0,
    PipelinestatisticnameClipperinvocations = 1,
    PipelinestatisticnameClipperprimitivesout = 2,
    PipelinestatisticnameFragmentshaderinvocations = 3,
    PipelinestatisticnameComputeshaderinvocations = 4,
    PipelinestatisticnameForce32 = 2147483647,
}

PowerPreference :: enum i32 {
    PowerpreferenceUndefined = 0,
    PowerpreferenceLowpower = 1,
    PowerpreferenceHighperformance = 2,
    PowerpreferenceForce32 = 2147483647,
}

PredefinedColorSpace :: enum i32 {
    PredefinedcolorspaceUndefined = 0,
    PredefinedcolorspaceSrgb = 1,
    PredefinedcolorspaceForce32 = 2147483647,
}

PresentMode :: enum i32 {
    PresentmodeImmediate = 0,
    PresentmodeMailbox = 1,
    PresentmodeFifo = 2,
    PresentmodeForce32 = 2147483647,
}

PrimitiveTopology :: enum i32 {
    PrimitivetopologyPointlist = 0,
    PrimitivetopologyLinelist = 1,
    PrimitivetopologyLinestrip = 2,
    PrimitivetopologyTrianglelist = 3,
    PrimitivetopologyTrianglestrip = 4,
    PrimitivetopologyForce32 = 2147483647,
}

QueryType :: enum i32 {
    QuerytypeOcclusion = 0,
    QuerytypePipelinestatistics = 1,
    QuerytypeTimestamp = 2,
    QuerytypeForce32 = 2147483647,
}

QueueWorkDoneStatus :: enum i32 {
    QueueworkdonestatusSuccess = 0,
    QueueworkdonestatusError = 1,
    QueueworkdonestatusUnknown = 2,
    QueueworkdonestatusDevicelost = 3,
    QueueworkdonestatusForce32 = 2147483647,
}

RenderPassTimestampLocation :: enum i32 {
    RenderpasstimestamplocationBeginning = 0,
    RenderpasstimestamplocationEnd = 1,
    RenderpasstimestamplocationForce32 = 2147483647,
}

RequestAdapterStatus :: enum i32 {
    RequestadapterstatusSuccess = 0,
    RequestadapterstatusUnavailable = 1,
    RequestadapterstatusError = 2,
    RequestadapterstatusUnknown = 3,
    RequestadapterstatusForce32 = 2147483647,
}

RequestDeviceStatus :: enum i32 {
    RequestdevicestatusSuccess = 0,
    RequestdevicestatusError = 1,
    RequestdevicestatusUnknown = 2,
    RequestdevicestatusForce32 = 2147483647,
}

SType :: enum i32 {
    StypeInvalid = 0,
    StypeSurfacedescriptorfrommetallayer = 1,
    StypeSurfacedescriptorfromwindowshwnd = 2,
    StypeSurfacedescriptorfromxlibwindow = 3,
    StypeSurfacedescriptorfromcanvashtmlselector = 4,
    StypeShadermodulespirvdescriptor = 5,
    StypeShadermodulewgsldescriptor = 6,
    StypePrimitivedepthclipcontrol = 7,
    StypeSurfacedescriptorfromwaylandsurface = 8,
    StypeSurfacedescriptorfromandroidnativewindow = 9,
    StypeSurfacedescriptorfromxcbwindow = 10,
    StypeForce32 = 2147483647,
}

SamplerBindingType :: enum i32 {
    SamplerbindingtypeUndefined = 0,
    SamplerbindingtypeFiltering = 1,
    SamplerbindingtypeNonfiltering = 2,
    SamplerbindingtypeComparison = 3,
    SamplerbindingtypeForce32 = 2147483647,
}

StencilOperation :: enum i32 {
    StenciloperationKeep = 0,
    StenciloperationZero = 1,
    StenciloperationReplace = 2,
    StenciloperationInvert = 3,
    StenciloperationIncrementclamp = 4,
    StenciloperationDecrementclamp = 5,
    StenciloperationIncrementwrap = 6,
    StenciloperationDecrementwrap = 7,
    StenciloperationForce32 = 2147483647,
}

StorageTextureAccess :: enum i32 {
    StoragetextureaccessUndefined = 0,
    StoragetextureaccessWriteonly = 1,
    StoragetextureaccessForce32 = 2147483647,
}

StoreOp :: enum i32 {
    StoreopUndefined = 0,
    StoreopStore = 1,
    StoreopDiscard = 2,
    StoreopForce32 = 2147483647,
}

TextureAspect :: enum i32 {
    TextureaspectAll = 0,
    TextureaspectStencilonly = 1,
    TextureaspectDepthonly = 2,
    TextureaspectForce32 = 2147483647,
}

TextureComponentType :: enum i32 {
    TexturecomponenttypeFloat = 0,
    TexturecomponenttypeSint = 1,
    TexturecomponenttypeUint = 2,
    TexturecomponenttypeDepthcomparison = 3,
    TexturecomponenttypeForce32 = 2147483647,
}

TextureDimension :: enum i32 {
    Texturedimension1D = 0,
    Texturedimension2D = 1,
    Texturedimension3D = 2,
    TexturedimensionForce32 = 2147483647,
}

TextureFormat :: enum i32 {
    TextureformatUndefined = 0,
    TextureformatR8Unorm = 1,
    TextureformatR8Snorm = 2,
    TextureformatR8Uint = 3,
    TextureformatR8Sint = 4,
    TextureformatR16Uint = 5,
    TextureformatR16Sint = 6,
    TextureformatR16Float = 7,
    TextureformatRg8Unorm = 8,
    TextureformatRg8Snorm = 9,
    TextureformatRg8Uint = 10,
    TextureformatRg8Sint = 11,
    TextureformatR32Float = 12,
    TextureformatR32Uint = 13,
    TextureformatR32Sint = 14,
    TextureformatRg16Uint = 15,
    TextureformatRg16Sint = 16,
    TextureformatRg16Float = 17,
    TextureformatRgba8Unorm = 18,
    TextureformatRgba8Unormsrgb = 19,
    TextureformatRgba8Snorm = 20,
    TextureformatRgba8Uint = 21,
    TextureformatRgba8Sint = 22,
    TextureformatBgra8Unorm = 23,
    TextureformatBgra8Unormsrgb = 24,
    TextureformatRgb10A2Unorm = 25,
    TextureformatRg11B10Ufloat = 26,
    TextureformatRgb9E5Ufloat = 27,
    TextureformatRg32Float = 28,
    TextureformatRg32Uint = 29,
    TextureformatRg32Sint = 30,
    TextureformatRgba16Uint = 31,
    TextureformatRgba16Sint = 32,
    TextureformatRgba16Float = 33,
    TextureformatRgba32Float = 34,
    TextureformatRgba32Uint = 35,
    TextureformatRgba32Sint = 36,
    TextureformatStencil8 = 37,
    TextureformatDepth16Unorm = 38,
    TextureformatDepth24Plus = 39,
    TextureformatDepth24Plusstencil8 = 40,
    TextureformatDepth24Unormstencil8 = 41,
    TextureformatDepth32Float = 42,
    TextureformatDepth32Floatstencil8 = 43,
    TextureformatBc1Rgbaunorm = 44,
    TextureformatBc1Rgbaunormsrgb = 45,
    TextureformatBc2Rgbaunorm = 46,
    TextureformatBc2Rgbaunormsrgb = 47,
    TextureformatBc3Rgbaunorm = 48,
    TextureformatBc3Rgbaunormsrgb = 49,
    TextureformatBc4Runorm = 50,
    TextureformatBc4Rsnorm = 51,
    TextureformatBc5Rgunorm = 52,
    TextureformatBc5Rgsnorm = 53,
    TextureformatBc6Hrgbufloat = 54,
    TextureformatBc6Hrgbfloat = 55,
    TextureformatBc7Rgbaunorm = 56,
    TextureformatBc7Rgbaunormsrgb = 57,
    TextureformatEtc2Rgb8Unorm = 58,
    TextureformatEtc2Rgb8Unormsrgb = 59,
    TextureformatEtc2Rgb8A1Unorm = 60,
    TextureformatEtc2Rgb8A1Unormsrgb = 61,
    TextureformatEtc2Rgba8Unorm = 62,
    TextureformatEtc2Rgba8Unormsrgb = 63,
    TextureformatEacr11Unorm = 64,
    TextureformatEacr11Snorm = 65,
    TextureformatEacrg11Unorm = 66,
    TextureformatEacrg11Snorm = 67,
    TextureformatAstc4X4Unorm = 68,
    TextureformatAstc4X4Unormsrgb = 69,
    TextureformatAstc5X4Unorm = 70,
    TextureformatAstc5X4Unormsrgb = 71,
    TextureformatAstc5X5Unorm = 72,
    TextureformatAstc5X5Unormsrgb = 73,
    TextureformatAstc6X5Unorm = 74,
    TextureformatAstc6X5Unormsrgb = 75,
    TextureformatAstc6X6Unorm = 76,
    TextureformatAstc6X6Unormsrgb = 77,
    TextureformatAstc8X5Unorm = 78,
    TextureformatAstc8X5Unormsrgb = 79,
    TextureformatAstc8X6Unorm = 80,
    TextureformatAstc8X6Unormsrgb = 81,
    TextureformatAstc8X8Unorm = 82,
    TextureformatAstc8X8Unormsrgb = 83,
    TextureformatAstc10X5Unorm = 84,
    TextureformatAstc10X5Unormsrgb = 85,
    TextureformatAstc10X6Unorm = 86,
    TextureformatAstc10X6Unormsrgb = 87,
    TextureformatAstc10X8Unorm = 88,
    TextureformatAstc10X8Unormsrgb = 89,
    TextureformatAstc10X10Unorm = 90,
    TextureformatAstc10X10Unormsrgb = 91,
    TextureformatAstc12X10Unorm = 92,
    TextureformatAstc12X10Unormsrgb = 93,
    TextureformatAstc12X12Unorm = 94,
    TextureformatAstc12X12Unormsrgb = 95,
    TextureformatForce32 = 2147483647,
}

TextureSampleType :: enum i32 {
    TexturesampletypeUndefined = 0,
    TexturesampletypeFloat = 1,
    TexturesampletypeUnfilterablefloat = 2,
    TexturesampletypeDepth = 3,
    TexturesampletypeSint = 4,
    TexturesampletypeUint = 5,
    TexturesampletypeForce32 = 2147483647,
}

TextureViewDimension :: enum i32 {
    TextureviewdimensionUndefined = 0,
    Textureviewdimension1D = 1,
    Textureviewdimension2D = 2,
    Textureviewdimension2Darray = 3,
    TextureviewdimensionCube = 4,
    TextureviewdimensionCubearray = 5,
    Textureviewdimension3D = 6,
    TextureviewdimensionForce32 = 2147483647,
}

VertexFormat :: enum i32 {
    VertexformatUndefined = 0,
    VertexformatUint8X2 = 1,
    VertexformatUint8X4 = 2,
    VertexformatSint8X2 = 3,
    VertexformatSint8X4 = 4,
    VertexformatUnorm8X2 = 5,
    VertexformatUnorm8X4 = 6,
    VertexformatSnorm8X2 = 7,
    VertexformatSnorm8X4 = 8,
    VertexformatUint16X2 = 9,
    VertexformatUint16X4 = 10,
    VertexformatSint16X2 = 11,
    VertexformatSint16X4 = 12,
    VertexformatUnorm16X2 = 13,
    VertexformatUnorm16X4 = 14,
    VertexformatSnorm16X2 = 15,
    VertexformatSnorm16X4 = 16,
    VertexformatFloat16X2 = 17,
    VertexformatFloat16X4 = 18,
    VertexformatFloat32 = 19,
    VertexformatFloat32X2 = 20,
    VertexformatFloat32X3 = 21,
    VertexformatFloat32X4 = 22,
    VertexformatUint32 = 23,
    VertexformatUint32X2 = 24,
    VertexformatUint32X3 = 25,
    VertexformatUint32X4 = 26,
    VertexformatSint32 = 27,
    VertexformatSint32X2 = 28,
    VertexformatSint32X3 = 29,
    VertexformatSint32X4 = 30,
    VertexformatForce32 = 2147483647,
}

VertexStepMode :: enum i32 {
    VertexstepmodeVertex = 0,
    VertexstepmodeInstance = 1,
    VertexstepmodeForce32 = 2147483647,
}

BufferUsage :: enum i32 {
    BufferusageNone = 0,
    BufferusageMapread = 1,
    BufferusageMapwrite = 2,
    BufferusageCopysrc = 4,
    BufferusageCopydst = 8,
    BufferusageIndex = 16,
    BufferusageVertex = 32,
    BufferusageUniform = 64,
    BufferusageStorage = 128,
    BufferusageIndirect = 256,
    BufferusageQueryresolve = 512,
    BufferusageForce32 = 2147483647,
}

ColorWriteMask :: enum i32 {
    ColorwritemaskNone = 0,
    ColorwritemaskRed = 1,
    ColorwritemaskGreen = 2,
    ColorwritemaskBlue = 4,
    ColorwritemaskAlpha = 8,
    ColorwritemaskAll = 15,
    ColorwritemaskForce32 = 2147483647,
}

MapMode :: enum i32 {
    MapmodeNone = 0,
    MapmodeRead = 1,
    MapmodeWrite = 2,
    MapmodeForce32 = 2147483647,
}

ShaderStage :: enum i32 {
    ShaderstageNone = 0,
    ShaderstageVertex = 1,
    ShaderstageFragment = 2,
    ShaderstageCompute = 4,
    ShaderstageForce32 = 2147483647,
}

TextureUsage :: enum i32 {
    TextureusageNone = 0,
    TextureusageCopysrc = 1,
    TextureusageCopydst = 2,
    TextureusageTexturebinding = 4,
    TextureusageStoragebinding = 8,
    TextureusageRenderattachment = 16,
    TextureusageForce32 = 2147483647,
}

AdapterImpl :: struct {}

BindGroupImpl :: struct {}

BindGroupLayoutImpl :: struct {}

BufferImpl :: struct {}

CommandBufferImpl :: struct {}

CommandEncoderImpl :: struct {}

ComputePassEncoderImpl :: struct {}

ComputePipelineImpl :: struct {}

DeviceImpl :: struct {}

InstanceImpl :: struct {}

PipelineLayoutImpl :: struct {}

QuerySetImpl :: struct {}

QueueImpl :: struct {}

RenderBundleImpl :: struct {}

RenderBundleEncoderImpl :: struct {}

RenderPassEncoderImpl :: struct {}

RenderPipelineImpl :: struct {}

SamplerImpl :: struct {}

ShaderModuleImpl :: struct {}

SurfaceImpl :: struct {}

SwapChainImpl :: struct {}

TextureImpl :: struct {}

TextureViewImpl :: struct {}

ChainedStruct :: struct {
    next : ^ChainedStruct,
    s_type : SType,
}

ChainedStructOut :: struct {
    next : ^ChainedStructOut,
    s_type : SType,
}

AdapterProperties :: struct {
    next_in_chain : ^ChainedStructOut,
    vendor_id : u32,
    device_id : u32,
    name : cstring,
    driver_description : cstring,
    adapter_type : AdapterType,
    backend_type : BackendType,
}

BindGroupEntry :: struct {
    next_in_chain : ^ChainedStruct,
    binding : u32,
    buffer : Buffer,
    offset : u64,
    size : u64,
    sampler : Sampler,
    texture_view : TextureView,
}

BlendComponent :: struct {
    operation : BlendOperation,
    src_factor : BlendFactor,
    dst_factor : BlendFactor,
}

BufferBindingLayout :: struct {
    next_in_chain : ^ChainedStruct,
    type : BufferBindingType,
    has_dynamic_offset : Bool,
    min_binding_size : u64,
}

BufferDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    usage : u32,
    size : u64,
    mapped_at_creation : Bool,
}

Color :: struct {
    r : _c.double,
    g : _c.double,
    b : _c.double,
    a : _c.double,
}

CommandBufferDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
}

CommandEncoderDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
}

CompilationMessage :: struct {
    next_in_chain : ^ChainedStruct,
    message : cstring,
    type : CompilationMessageType,
    line_num : u64,
    line_pos : u64,
    offset : u64,
    length : u64,
}

ComputePassTimestampWrite :: struct {
    query_set : QuerySet,
    query_index : u32,
    location : ComputePassTimestampLocation,
}

ConstantEntry :: struct {
    next_in_chain : ^ChainedStruct,
    key : cstring,
    value : _c.double,
}

Extent3D :: struct {
    width : u32,
    height : u32,
    depth_or_array_layers : u32,
}

InstanceDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
}

Limits :: struct {
    max_texture_dimension1_d : u32,
    max_texture_dimension2_d : u32,
    max_texture_dimension3_d : u32,
    max_texture_array_layers : u32,
    max_bind_groups : u32,
    max_dynamic_uniform_buffers_per_pipeline_layout : u32,
    max_dynamic_storage_buffers_per_pipeline_layout : u32,
    max_sampled_textures_per_shader_stage : u32,
    max_samplers_per_shader_stage : u32,
    max_storage_buffers_per_shader_stage : u32,
    max_storage_textures_per_shader_stage : u32,
    max_uniform_buffers_per_shader_stage : u32,
    max_uniform_buffer_binding_size : u64,
    max_storage_buffer_binding_size : u64,
    min_uniform_buffer_offset_alignment : u32,
    min_storage_buffer_offset_alignment : u32,
    max_vertex_buffers : u32,
    max_vertex_attributes : u32,
    max_vertex_buffer_array_stride : u32,
    max_inter_stage_shader_components : u32,
    max_compute_workgroup_storage_size : u32,
    max_compute_invocations_per_workgroup : u32,
    max_compute_workgroup_size_x : u32,
    max_compute_workgroup_size_y : u32,
    max_compute_workgroup_size_z : u32,
    max_compute_workgroups_per_dimension : u32,
}

MultisampleState :: struct {
    next_in_chain : ^ChainedStruct,
    count : u32,
    mask : u32,
    alpha_to_coverage_enabled : Bool,
}

Origin3D :: struct {
    x : u32,
    y : u32,
    z : u32,
}

PipelineLayoutDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    bind_group_layout_count : u32,
    bind_group_layouts : ^BindGroupLayout,
}

PrimitiveDepthClipControl :: struct {
    chain : ChainedStruct,
    unclipped_depth : Bool,
}

PrimitiveState :: struct {
    next_in_chain : ^ChainedStruct,
    topology : PrimitiveTopology,
    strip_index_format : IndexFormat,
    front_face : FrontFace,
    cull_mode : CullMode,
}

QuerySetDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    type : QueryType,
    count : u32,
    pipeline_statistics : ^PipelineStatisticName,
    pipeline_statistics_count : u32,
}

QueueDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
}

RenderBundleDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
}

RenderBundleEncoderDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    color_formats_count : u32,
    color_formats : ^TextureFormat,
    depth_stencil_format : TextureFormat,
    sample_count : u32,
    depth_read_only : Bool,
    stencil_read_only : Bool,
}

RenderPassDepthStencilAttachment :: struct {
    view : TextureView,
    depth_load_op : LoadOp,
    depth_store_op : StoreOp,
    depth_clear_value : _c.float,
    depth_read_only : Bool,
    stencil_load_op : LoadOp,
    stencil_store_op : StoreOp,
    stencil_clear_value : u32,
    stencil_read_only : Bool,
}

RenderPassTimestampWrite :: struct {
    query_set : QuerySet,
    query_index : u32,
    location : RenderPassTimestampLocation,
}

RequestAdapterOptions :: struct {
    next_in_chain : ^ChainedStruct,
    compatible_surface : Surface,
    power_preference : PowerPreference,
    force_fallback_adapter : Bool,
}

SamplerBindingLayout :: struct {
    next_in_chain : ^ChainedStruct,
    type : SamplerBindingType,
}

SamplerDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    address_mode_u : AddressMode,
    address_mode_v : AddressMode,
    address_mode_w : AddressMode,
    mag_filter : FilterMode,
    min_filter : FilterMode,
    mipmap_filter : MipmapFilterMode,
    lod_min_clamp : _c.float,
    lod_max_clamp : _c.float,
    compare : CompareFunction,
    max_anisotropy : u16,
}

ShaderModuleCompilationHint :: struct {
    next_in_chain : ^ChainedStruct,
    entry_point : cstring,
    layout : PipelineLayout,
}

ShaderModuleSpirvDescriptor :: struct {
    chain : ChainedStruct,
    code_size : u32,
    code : ^u32,
}

ShaderModuleWgslDescriptor :: struct {
    chain : ChainedStruct,
    code : cstring,
}

StencilFaceState :: struct {
    compare : CompareFunction,
    fail_op : StencilOperation,
    depth_fail_op : StencilOperation,
    pass_op : StencilOperation,
}

StorageTextureBindingLayout :: struct {
    next_in_chain : ^ChainedStruct,
    access : StorageTextureAccess,
    format : TextureFormat,
    view_dimension : TextureViewDimension,
}

SurfaceDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
}

SurfaceDescriptorFromAndroidNativeWindow :: struct {
    chain : ChainedStruct,
    window : rawptr,
}

SurfaceDescriptorFromCanvasHtmlSelector :: struct {
    chain : ChainedStruct,
    selector : cstring,
}

SurfaceDescriptorFromMetalLayer :: struct {
    chain : ChainedStruct,
    layer : rawptr,
}

SurfaceDescriptorFromWaylandSurface :: struct {
    chain : ChainedStruct,
    display : rawptr,
    surface : rawptr,
}

SurfaceDescriptorFromWindowsHwnd :: struct {
    chain : ChainedStruct,
    hinstance : rawptr,
    hwnd : rawptr,
}

SurfaceDescriptorFromXcbWindow :: struct {
    chain : ChainedStruct,
    connection : rawptr,
    window : u32,
}

SurfaceDescriptorFromXlibWindow :: struct {
    chain : ChainedStruct,
    display : rawptr,
    window : u32,
}

SwapChainDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    usage : u32,
    format : TextureFormat,
    width : u32,
    height : u32,
    present_mode : PresentMode,
}

TextureBindingLayout :: struct {
    next_in_chain : ^ChainedStruct,
    sample_type : TextureSampleType,
    view_dimension : TextureViewDimension,
    multisampled : Bool,
}

TextureDataLayout :: struct {
    next_in_chain : ^ChainedStruct,
    offset : u64,
    bytes_per_row : u32,
    rows_per_image : u32,
}

TextureViewDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    format : TextureFormat,
    dimension : TextureViewDimension,
    base_mip_level : u32,
    mip_level_count : u32,
    base_array_layer : u32,
    array_layer_count : u32,
    aspect : TextureAspect,
}

VertexAttribute :: struct {
    format : VertexFormat,
    offset : u64,
    shader_location : u32,
}

BindGroupDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    layout : BindGroupLayout,
    entry_count : u32,
    entries : ^BindGroupEntry,
}

BindGroupLayoutEntry :: struct {
    next_in_chain : ^ChainedStruct,
    binding : u32,
    visibility : u32,
    buffer : BufferBindingLayout,
    sampler : SamplerBindingLayout,
    texture : TextureBindingLayout,
    storage_texture : StorageTextureBindingLayout,
}

BlendState :: struct {
    color : BlendComponent,
    alpha : BlendComponent,
}

CompilationInfo :: struct {
    next_in_chain : ^ChainedStruct,
    message_count : u32,
    messages : ^CompilationMessage,
}

ComputePassDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    timestamp_write_count : u32,
    timestamp_writes : ^ComputePassTimestampWrite,
}

DepthStencilState :: struct {
    next_in_chain : ^ChainedStruct,
    format : TextureFormat,
    depth_write_enabled : Bool,
    depth_compare : CompareFunction,
    stencil_front : StencilFaceState,
    stencil_back : StencilFaceState,
    stencil_read_mask : u32,
    stencil_write_mask : u32,
    depth_bias : i32,
    depth_bias_slope_scale : _c.float,
    depth_bias_clamp : _c.float,
}

ImageCopyBuffer :: struct {
    next_in_chain : ^ChainedStruct,
    layout : TextureDataLayout,
    buffer : Buffer,
}

ImageCopyTexture :: struct {
    next_in_chain : ^ChainedStruct,
    texture : Texture,
    mip_level : u32,
    origin : Origin3D,
    aspect : TextureAspect,
}

ProgrammableStageDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    module : ShaderModule,
    entry_point : cstring,
    constant_count : u32,
    constants : ^ConstantEntry,
}

RenderPassColorAttachment :: struct {
    view : TextureView,
    resolve_target : TextureView,
    load_op : LoadOp,
    store_op : StoreOp,
    clear_value : Color,
}

RequiredLimits :: struct {
    next_in_chain : ^ChainedStruct,
    limits : Limits,
}

ShaderModuleDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    hint_count : u32,
    hints : ^ShaderModuleCompilationHint,
}

SupportedLimits :: struct {
    next_in_chain : ^ChainedStructOut,
    limits : Limits,
}

TextureDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    usage : u32,
    dimension : TextureDimension,
    size : Extent3D,
    format : TextureFormat,
    mip_level_count : u32,
    sample_count : u32,
    view_format_count : u32,
    view_formats : ^TextureFormat,
}

VertexBufferLayout :: struct {
    array_stride : u64,
    step_mode : VertexStepMode,
    attribute_count : u32,
    attributes : ^VertexAttribute,
}

BindGroupLayoutDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    entry_count : u32,
    entries : ^BindGroupLayoutEntry,
}

ColorTargetState :: struct {
    next_in_chain : ^ChainedStruct,
    format : TextureFormat,
    blend : ^BlendState,
    write_mask : u32,
}

ComputePipelineDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    layout : PipelineLayout,
    compute : ProgrammableStageDescriptor,
}

DeviceDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    required_features_count : u32,
    required_features : ^FeatureName,
    required_limits : ^RequiredLimits,
    default_queue : QueueDescriptor,
}

RenderPassDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    color_attachment_count : u32,
    color_attachments : ^RenderPassColorAttachment,
    depth_stencil_attachment : ^RenderPassDepthStencilAttachment,
    occlusion_query_set : QuerySet,
    timestamp_write_count : u32,
    timestamp_writes : ^RenderPassTimestampWrite,
}

VertexState :: struct {
    next_in_chain : ^ChainedStruct,
    module : ShaderModule,
    entry_point : cstring,
    constant_count : u32,
    constants : ^ConstantEntry,
    buffer_count : u32,
    buffers : ^VertexBufferLayout,
}

FragmentState :: struct {
    next_in_chain : ^ChainedStruct,
    module : ShaderModule,
    entry_point : cstring,
    constant_count : u32,
    constants : ^ConstantEntry,
    target_count : u32,
    targets : ^ColorTargetState,
}

RenderPipelineDescriptor :: struct {
    next_in_chain : ^ChainedStruct,
    label : cstring,
    layout : PipelineLayout,
    vertex : VertexState,
    primitive : PrimitiveState,
    depth_stencil : ^DepthStencilState,
    multisample : MultisampleState,
    fragment : ^FragmentState,
}

@(default_calling_convention="c")
foreign wgpu_native {

    @(link_name="wgpuCreateInstance")
    create_instance :: proc(descriptor : ^InstanceDescriptor) -> Instance ---

    @(link_name="wgpuGetProcAddress")
    get_proc_address :: proc(device : Device, proc_name : cstring) -> Proc ---

    @(link_name="wgpuAdapterEnumerateFeatures")
    adapter_enumerate_features :: proc(adapter : Adapter, features : ^FeatureName) -> _c.size_t ---

    @(link_name="wgpuAdapterGetLimits")
    adapter_get_limits :: proc(adapter : Adapter, limits : ^SupportedLimits) -> Bool ---

    @(link_name="wgpuAdapterGetProperties")
    adapter_get_properties :: proc(adapter : Adapter, properties : ^AdapterProperties) ---

    @(link_name="wgpuAdapterHasFeature")
    adapter_has_feature :: proc(adapter : Adapter, feature : FeatureName) -> Bool ---

    @(link_name="wgpuAdapterRequestDevice")
    adapter_request_device :: proc(adapter : Adapter, descriptor : ^DeviceDescriptor, callback : RequestDeviceCallback, userdata : rawptr) ---

    @(link_name="wgpuBindGroupSetLabel")
    bind_group_set_label :: proc(bind_group : BindGroup, label : cstring) ---

    @(link_name="wgpuBindGroupLayoutSetLabel")
    bind_group_layout_set_label :: proc(bind_group_layout : BindGroupLayout, label : cstring) ---

    @(link_name="wgpuBufferDestroy")
    buffer_destroy :: proc(buffer : Buffer) ---

    @(link_name="wgpuBufferGetConstMappedRange")
    buffer_get_const_mapped_range :: proc(buffer : Buffer, offset : _c.size_t, size : _c.size_t) -> rawptr ---

    @(link_name="wgpuBufferGetMappedRange")
    buffer_get_mapped_range :: proc(buffer : Buffer, offset : _c.size_t, size : _c.size_t) -> rawptr ---

    @(link_name="wgpuBufferMapAsync")
    buffer_map_async :: proc(buffer : Buffer, mode : u32, offset : _c.size_t, size : _c.size_t, callback : BufferMapCallback, userdata : rawptr) ---

    @(link_name="wgpuBufferSetLabel")
    buffer_set_label :: proc(buffer : Buffer, label : cstring) ---

    @(link_name="wgpuBufferUnmap")
    buffer_unmap :: proc(buffer : Buffer) ---

    @(link_name="wgpuCommandBufferSetLabel")
    command_buffer_set_label :: proc(command_buffer : CommandBuffer, label : cstring) ---

    @(link_name="wgpuCommandEncoderBeginComputePass")
    command_encoder_begin_compute_pass :: proc(command_encoder : CommandEncoder, descriptor : ^ComputePassDescriptor) -> ComputePassEncoder ---

    @(link_name="wgpuCommandEncoderBeginRenderPass")
    command_encoder_begin_render_pass :: proc(command_encoder : CommandEncoder, descriptor : ^RenderPassDescriptor) -> RenderPassEncoder ---

    @(link_name="wgpuCommandEncoderClearBuffer")
    command_encoder_clear_buffer :: proc(command_encoder : CommandEncoder, buffer : Buffer, offset : u64, size : u64) ---

    @(link_name="wgpuCommandEncoderCopyBufferToBuffer")
    command_encoder_copy_buffer_to_buffer :: proc(command_encoder : CommandEncoder, source : Buffer, source_offset : u64, destination : Buffer, destination_offset : u64, size : u64) ---

    @(link_name="wgpuCommandEncoderCopyBufferToTexture")
    command_encoder_copy_buffer_to_texture :: proc(command_encoder : CommandEncoder, source : ^ImageCopyBuffer, destination : ^ImageCopyTexture, copy_size : ^Extent3D) ---

    @(link_name="wgpuCommandEncoderCopyTextureToBuffer")
    command_encoder_copy_texture_to_buffer :: proc(command_encoder : CommandEncoder, source : ^ImageCopyTexture, destination : ^ImageCopyBuffer, copy_size : ^Extent3D) ---

    @(link_name="wgpuCommandEncoderCopyTextureToTexture")
    command_encoder_copy_texture_to_texture :: proc(command_encoder : CommandEncoder, source : ^ImageCopyTexture, destination : ^ImageCopyTexture, copy_size : ^Extent3D) ---

    @(link_name="wgpuCommandEncoderFinish")
    command_encoder_finish :: proc(command_encoder : CommandEncoder, descriptor : ^CommandBufferDescriptor) -> CommandBuffer ---

    @(link_name="wgpuCommandEncoderInsertDebugMarker")
    command_encoder_insert_debug_marker :: proc(command_encoder : CommandEncoder, marker_label : cstring) ---

    @(link_name="wgpuCommandEncoderPopDebugGroup")
    command_encoder_pop_debug_group :: proc(command_encoder : CommandEncoder) ---

    @(link_name="wgpuCommandEncoderPushDebugGroup")
    command_encoder_push_debug_group :: proc(command_encoder : CommandEncoder, group_label : cstring) ---

    @(link_name="wgpuCommandEncoderResolveQuerySet")
    command_encoder_resolve_query_set :: proc(command_encoder : CommandEncoder, query_set : QuerySet, first_query : u32, query_count : u32, destination : Buffer, destination_offset : u64) ---

    @(link_name="wgpuCommandEncoderSetLabel")
    command_encoder_set_label :: proc(command_encoder : CommandEncoder, label : cstring) ---

    @(link_name="wgpuCommandEncoderWriteTimestamp")
    command_encoder_write_timestamp :: proc(command_encoder : CommandEncoder, query_set : QuerySet, query_index : u32) ---

    @(link_name="wgpuComputePassEncoderBeginPipelineStatisticsQuery")
    compute_pass_encoder_begin_pipeline_statistics_query :: proc(compute_pass_encoder : ComputePassEncoder, query_set : QuerySet, query_index : u32) ---

    @(link_name="wgpuComputePassEncoderDispatchWorkgroups")
    compute_pass_encoder_dispatch_workgroups :: proc(compute_pass_encoder : ComputePassEncoder, workgroup_count_x : u32, workgroup_count_y : u32, workgroup_count_z : u32) ---

    @(link_name="wgpuComputePassEncoderDispatchWorkgroupsIndirect")
    compute_pass_encoder_dispatch_workgroups_indirect :: proc(compute_pass_encoder : ComputePassEncoder, indirect_buffer : Buffer, indirect_offset : u64) ---

    @(link_name="wgpuComputePassEncoderEnd")
    compute_pass_encoder_end :: proc(compute_pass_encoder : ComputePassEncoder) ---

    @(link_name="wgpuComputePassEncoderEndPipelineStatisticsQuery")
    compute_pass_encoder_end_pipeline_statistics_query :: proc(compute_pass_encoder : ComputePassEncoder) ---

    @(link_name="wgpuComputePassEncoderInsertDebugMarker")
    compute_pass_encoder_insert_debug_marker :: proc(compute_pass_encoder : ComputePassEncoder, marker_label : cstring) ---

    @(link_name="wgpuComputePassEncoderPopDebugGroup")
    compute_pass_encoder_pop_debug_group :: proc(compute_pass_encoder : ComputePassEncoder) ---

    @(link_name="wgpuComputePassEncoderPushDebugGroup")
    compute_pass_encoder_push_debug_group :: proc(compute_pass_encoder : ComputePassEncoder, group_label : cstring) ---

    @(link_name="wgpuComputePassEncoderSetBindGroup")
    compute_pass_encoder_set_bind_group :: proc(compute_pass_encoder : ComputePassEncoder, group_index : u32, group : BindGroup, dynamic_offset_count : u32, dynamic_offsets : ^u32) ---

    @(link_name="wgpuComputePassEncoderSetLabel")
    compute_pass_encoder_set_label :: proc(compute_pass_encoder : ComputePassEncoder, label : cstring) ---

    @(link_name="wgpuComputePassEncoderSetPipeline")
    compute_pass_encoder_set_pipeline :: proc(compute_pass_encoder : ComputePassEncoder, pipeline : ComputePipeline) ---

    @(link_name="wgpuComputePipelineGetBindGroupLayout")
    compute_pipeline_get_bind_group_layout :: proc(compute_pipeline : ComputePipeline, group_index : u32) -> BindGroupLayout ---

    @(link_name="wgpuComputePipelineSetLabel")
    compute_pipeline_set_label :: proc(compute_pipeline : ComputePipeline, label : cstring) ---

    @(link_name="wgpuDeviceCreateBindGroup")
    device_create_bind_group :: proc(device : Device, descriptor : ^BindGroupDescriptor) -> BindGroup ---

    @(link_name="wgpuDeviceCreateBindGroupLayout")
    device_create_bind_group_layout :: proc(device : Device, descriptor : ^BindGroupLayoutDescriptor) -> BindGroupLayout ---

    @(link_name="wgpuDeviceCreateBuffer")
    device_create_buffer :: proc(device : Device, descriptor : ^BufferDescriptor) -> Buffer ---

    @(link_name="wgpuDeviceCreateCommandEncoder")
    device_create_command_encoder :: proc(device : Device, descriptor : ^CommandEncoderDescriptor) -> CommandEncoder ---

    @(link_name="wgpuDeviceCreateComputePipeline")
    device_create_compute_pipeline :: proc(device : Device, descriptor : ^ComputePipelineDescriptor) -> ComputePipeline ---

    @(link_name="wgpuDeviceCreateComputePipelineAsync")
    device_create_compute_pipeline_async :: proc(device : Device, descriptor : ^ComputePipelineDescriptor, callback : CreateComputePipelineAsyncCallback, userdata : rawptr) ---

    @(link_name="wgpuDeviceCreatePipelineLayout")
    device_create_pipeline_layout :: proc(device : Device, descriptor : ^PipelineLayoutDescriptor) -> PipelineLayout ---

    @(link_name="wgpuDeviceCreateQuerySet")
    device_create_query_set :: proc(device : Device, descriptor : ^QuerySetDescriptor) -> QuerySet ---

    @(link_name="wgpuDeviceCreateRenderBundleEncoder")
    device_create_render_bundle_encoder :: proc(device : Device, descriptor : ^RenderBundleEncoderDescriptor) -> RenderBundleEncoder ---

    @(link_name="wgpuDeviceCreateRenderPipeline")
    device_create_render_pipeline :: proc(device : Device, descriptor : ^RenderPipelineDescriptor) -> RenderPipeline ---

    @(link_name="wgpuDeviceCreateRenderPipelineAsync")
    device_create_render_pipeline_async :: proc(device : Device, descriptor : ^RenderPipelineDescriptor, callback : CreateRenderPipelineAsyncCallback, userdata : rawptr) ---

    @(link_name="wgpuDeviceCreateSampler")
    device_create_sampler :: proc(device : Device, descriptor : ^SamplerDescriptor) -> Sampler ---

    @(link_name="wgpuDeviceCreateShaderModule")
    device_create_shader_module :: proc(device : Device, descriptor : ^ShaderModuleDescriptor) -> ShaderModule ---

    @(link_name="wgpuDeviceCreateSwapChain")
    device_create_swap_chain :: proc(device : Device, surface : Surface, descriptor : ^SwapChainDescriptor) -> SwapChain ---

    @(link_name="wgpuDeviceCreateTexture")
    device_create_texture :: proc(device : Device, descriptor : ^TextureDescriptor) -> Texture ---

    @(link_name="wgpuDeviceDestroy")
    device_destroy :: proc(device : Device) ---

    @(link_name="wgpuDeviceEnumerateFeatures")
    device_enumerate_features :: proc(device : Device, features : ^FeatureName) -> _c.size_t ---

    @(link_name="wgpuDeviceGetLimits")
    device_get_limits :: proc(device : Device, limits : ^SupportedLimits) -> Bool ---

    @(link_name="wgpuDeviceGetQueue")
    device_get_queue :: proc(device : Device) -> Queue ---

    @(link_name="wgpuDeviceHasFeature")
    device_has_feature :: proc(device : Device, feature : FeatureName) -> Bool ---

    @(link_name="wgpuDevicePopErrorScope")
    device_pop_error_scope :: proc(device : Device, callback : ErrorCallback, userdata : rawptr) -> Bool ---

    @(link_name="wgpuDevicePushErrorScope")
    device_push_error_scope :: proc(device : Device, filter : ErrorFilter) ---

    @(link_name="wgpuDeviceSetDeviceLostCallback")
    device_set_device_lost_callback :: proc(device : Device, callback : DeviceLostCallback, userdata : rawptr) ---

    @(link_name="wgpuDeviceSetLabel")
    device_set_label :: proc(device : Device, label : cstring) ---

    @(link_name="wgpuDeviceSetUncapturedErrorCallback")
    device_set_uncaptured_error_callback :: proc(device : Device, callback : ErrorCallback, userdata : rawptr) ---

    @(link_name="wgpuInstanceCreateSurface")
    instance_create_surface :: proc(instance : Instance, descriptor : ^SurfaceDescriptor) -> Surface ---

    @(link_name="wgpuInstanceProcessEvents")
    instance_process_events :: proc(instance : Instance) ---

    @(link_name="wgpuInstanceRequestAdapter")
    instance_request_adapter :: proc(instance : Instance, options : ^RequestAdapterOptions, callback : RequestAdapterCallback, userdata : rawptr) ---

    @(link_name="wgpuPipelineLayoutSetLabel")
    pipeline_layout_set_label :: proc(pipeline_layout : PipelineLayout, label : cstring) ---

    @(link_name="wgpuQuerySetDestroy")
    query_set_destroy :: proc(query_set : QuerySet) ---

    @(link_name="wgpuQuerySetSetLabel")
    query_set_set_label :: proc(query_set : QuerySet, label : cstring) ---

    @(link_name="wgpuQueueOnSubmittedWorkDone")
    queue_on_submitted_work_done :: proc(queue : Queue, callback : QueueWorkDoneCallback, userdata : rawptr) ---

    @(link_name="wgpuQueueSetLabel")
    queue_set_label :: proc(queue : Queue, label : cstring) ---

    @(link_name="wgpuQueueSubmit")
    queue_submit :: proc(queue : Queue, command_count : u32, commands : ^CommandBuffer) ---

    @(link_name="wgpuQueueWriteBuffer")
    queue_write_buffer :: proc(queue : Queue, buffer : Buffer, buffer_offset : u64, data : rawptr, size : _c.size_t) ---

    @(link_name="wgpuQueueWriteTexture")
    queue_write_texture :: proc(queue : Queue, destination : ^ImageCopyTexture, data : rawptr, data_size : _c.size_t, data_layout : ^TextureDataLayout, write_size : ^Extent3D) ---

    @(link_name="wgpuRenderBundleEncoderDraw")
    render_bundle_encoder_draw :: proc(render_bundle_encoder : RenderBundleEncoder, vertex_count : u32, instance_count : u32, first_vertex : u32, first_instance : u32) ---

    @(link_name="wgpuRenderBundleEncoderDrawIndexed")
    render_bundle_encoder_draw_indexed :: proc(render_bundle_encoder : RenderBundleEncoder, index_count : u32, instance_count : u32, first_index : u32, base_vertex : i32, first_instance : u32) ---

    @(link_name="wgpuRenderBundleEncoderDrawIndexedIndirect")
    render_bundle_encoder_draw_indexed_indirect :: proc(render_bundle_encoder : RenderBundleEncoder, indirect_buffer : Buffer, indirect_offset : u64) ---

    @(link_name="wgpuRenderBundleEncoderDrawIndirect")
    render_bundle_encoder_draw_indirect :: proc(render_bundle_encoder : RenderBundleEncoder, indirect_buffer : Buffer, indirect_offset : u64) ---

    @(link_name="wgpuRenderBundleEncoderFinish")
    render_bundle_encoder_finish :: proc(render_bundle_encoder : RenderBundleEncoder, descriptor : ^RenderBundleDescriptor) -> RenderBundle ---

    @(link_name="wgpuRenderBundleEncoderInsertDebugMarker")
    render_bundle_encoder_insert_debug_marker :: proc(render_bundle_encoder : RenderBundleEncoder, marker_label : cstring) ---

    @(link_name="wgpuRenderBundleEncoderPopDebugGroup")
    render_bundle_encoder_pop_debug_group :: proc(render_bundle_encoder : RenderBundleEncoder) ---

    @(link_name="wgpuRenderBundleEncoderPushDebugGroup")
    render_bundle_encoder_push_debug_group :: proc(render_bundle_encoder : RenderBundleEncoder, group_label : cstring) ---

    @(link_name="wgpuRenderBundleEncoderSetBindGroup")
    render_bundle_encoder_set_bind_group :: proc(render_bundle_encoder : RenderBundleEncoder, group_index : u32, group : BindGroup, dynamic_offset_count : u32, dynamic_offsets : ^u32) ---

    @(link_name="wgpuRenderBundleEncoderSetIndexBuffer")
    render_bundle_encoder_set_index_buffer :: proc(render_bundle_encoder : RenderBundleEncoder, buffer : Buffer, format : IndexFormat, offset : u64, size : u64) ---

    @(link_name="wgpuRenderBundleEncoderSetLabel")
    render_bundle_encoder_set_label :: proc(render_bundle_encoder : RenderBundleEncoder, label : cstring) ---

    @(link_name="wgpuRenderBundleEncoderSetPipeline")
    render_bundle_encoder_set_pipeline :: proc(render_bundle_encoder : RenderBundleEncoder, pipeline : RenderPipeline) ---

    @(link_name="wgpuRenderBundleEncoderSetVertexBuffer")
    render_bundle_encoder_set_vertex_buffer :: proc(render_bundle_encoder : RenderBundleEncoder, slot : u32, buffer : Buffer, offset : u64, size : u64) ---

    @(link_name="wgpuRenderPassEncoderBeginOcclusionQuery")
    render_pass_encoder_begin_occlusion_query :: proc(render_pass_encoder : RenderPassEncoder, query_index : u32) ---

    @(link_name="wgpuRenderPassEncoderBeginPipelineStatisticsQuery")
    render_pass_encoder_begin_pipeline_statistics_query :: proc(render_pass_encoder : RenderPassEncoder, query_set : QuerySet, query_index : u32) ---

    @(link_name="wgpuRenderPassEncoderDraw")
    render_pass_encoder_draw :: proc(render_pass_encoder : RenderPassEncoder, vertex_count : u32, instance_count : u32, first_vertex : u32, first_instance : u32) ---

    @(link_name="wgpuRenderPassEncoderDrawIndexed")
    render_pass_encoder_draw_indexed :: proc(render_pass_encoder : RenderPassEncoder, index_count : u32, instance_count : u32, first_index : u32, base_vertex : i32, first_instance : u32) ---

    @(link_name="wgpuRenderPassEncoderDrawIndexedIndirect")
    render_pass_encoder_draw_indexed_indirect :: proc(render_pass_encoder : RenderPassEncoder, indirect_buffer : Buffer, indirect_offset : u64) ---

    @(link_name="wgpuRenderPassEncoderDrawIndirect")
    render_pass_encoder_draw_indirect :: proc(render_pass_encoder : RenderPassEncoder, indirect_buffer : Buffer, indirect_offset : u64) ---

    @(link_name="wgpuRenderPassEncoderEnd")
    render_pass_encoder_end :: proc(render_pass_encoder : RenderPassEncoder) ---

    @(link_name="wgpuRenderPassEncoderEndOcclusionQuery")
    render_pass_encoder_end_occlusion_query :: proc(render_pass_encoder : RenderPassEncoder) ---

    @(link_name="wgpuRenderPassEncoderEndPipelineStatisticsQuery")
    render_pass_encoder_end_pipeline_statistics_query :: proc(render_pass_encoder : RenderPassEncoder) ---

    @(link_name="wgpuRenderPassEncoderExecuteBundles")
    render_pass_encoder_execute_bundles :: proc(render_pass_encoder : RenderPassEncoder, bundles_count : u32, bundles : ^RenderBundle) ---

    @(link_name="wgpuRenderPassEncoderInsertDebugMarker")
    render_pass_encoder_insert_debug_marker :: proc(render_pass_encoder : RenderPassEncoder, marker_label : cstring) ---

    @(link_name="wgpuRenderPassEncoderPopDebugGroup")
    render_pass_encoder_pop_debug_group :: proc(render_pass_encoder : RenderPassEncoder) ---

    @(link_name="wgpuRenderPassEncoderPushDebugGroup")
    render_pass_encoder_push_debug_group :: proc(render_pass_encoder : RenderPassEncoder, group_label : cstring) ---

    @(link_name="wgpuRenderPassEncoderSetBindGroup")
    render_pass_encoder_set_bind_group :: proc(render_pass_encoder : RenderPassEncoder, group_index : u32, group : BindGroup, dynamic_offset_count : u32, dynamic_offsets : ^u32) ---

    @(link_name="wgpuRenderPassEncoderSetBlendConstant")
    render_pass_encoder_set_blend_constant :: proc(render_pass_encoder : RenderPassEncoder, color : ^Color) ---

    @(link_name="wgpuRenderPassEncoderSetIndexBuffer")
    render_pass_encoder_set_index_buffer :: proc(render_pass_encoder : RenderPassEncoder, buffer : Buffer, format : IndexFormat, offset : u64, size : u64) ---

    @(link_name="wgpuRenderPassEncoderSetLabel")
    render_pass_encoder_set_label :: proc(render_pass_encoder : RenderPassEncoder, label : cstring) ---

    @(link_name="wgpuRenderPassEncoderSetPipeline")
    render_pass_encoder_set_pipeline :: proc(render_pass_encoder : RenderPassEncoder, pipeline : RenderPipeline) ---

    @(link_name="wgpuRenderPassEncoderSetScissorRect")
    render_pass_encoder_set_scissor_rect :: proc(render_pass_encoder : RenderPassEncoder, x : u32, y : u32, width : u32, height : u32) ---

    @(link_name="wgpuRenderPassEncoderSetStencilReference")
    render_pass_encoder_set_stencil_reference :: proc(render_pass_encoder : RenderPassEncoder, reference : u32) ---

    @(link_name="wgpuRenderPassEncoderSetVertexBuffer")
    render_pass_encoder_set_vertex_buffer :: proc(render_pass_encoder : RenderPassEncoder, slot : u32, buffer : Buffer, offset : u64, size : u64) ---

    @(link_name="wgpuRenderPassEncoderSetViewport")
    render_pass_encoder_set_viewport :: proc(render_pass_encoder : RenderPassEncoder, x : _c.float, y : _c.float, width : _c.float, height : _c.float, min_depth : _c.float, max_depth : _c.float) ---

    @(link_name="wgpuRenderPipelineGetBindGroupLayout")
    render_pipeline_get_bind_group_layout :: proc(render_pipeline : RenderPipeline, group_index : u32) -> BindGroupLayout ---

    @(link_name="wgpuRenderPipelineSetLabel")
    render_pipeline_set_label :: proc(render_pipeline : RenderPipeline, label : cstring) ---

    @(link_name="wgpuSamplerSetLabel")
    sampler_set_label :: proc(sampler : Sampler, label : cstring) ---

    @(link_name="wgpuShaderModuleGetCompilationInfo")
    shader_module_get_compilation_info :: proc(shader_module : ShaderModule, callback : CompilationInfoCallback, userdata : rawptr) ---

    @(link_name="wgpuShaderModuleSetLabel")
    shader_module_set_label :: proc(shader_module : ShaderModule, label : cstring) ---

    @(link_name="wgpuSurfaceGetPreferredFormat")
    surface_get_preferred_format :: proc(surface : Surface, adapter : Adapter) -> TextureFormat ---

    @(link_name="wgpuSwapChainGetCurrentTextureView")
    swap_chain_get_current_texture_view :: proc(swap_chain : SwapChain) -> TextureView ---

    @(link_name="wgpuSwapChainPresent")
    swap_chain_present :: proc(swap_chain : SwapChain) ---

    @(link_name="wgpuTextureCreateView")
    texture_create_view :: proc(texture : Texture, descriptor : ^TextureViewDescriptor) -> TextureView ---

    @(link_name="wgpuTextureDestroy")
    texture_destroy :: proc(texture : Texture) ---

    @(link_name="wgpuTextureSetLabel")
    texture_set_label :: proc(texture : Texture, label : cstring) ---

    @(link_name="wgpuTextureViewSetLabel")
    texture_view_set_label :: proc(texture_view : TextureView, label : cstring) ---

}
