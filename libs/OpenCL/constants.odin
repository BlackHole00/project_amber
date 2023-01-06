package OpenCL

// device_type
DEVICE_TYPE_DEFAULT         :: (1 << 0)
DEVICE_TYPE_CPU             :: (1 << 1)
DEVICE_TYPE_GPU             :: (1 << 2)
DEVICE_TYPE_ACCELERATOR     :: (1 << 3)
DEVICE_TYPE_CUSTOM          :: (1 << 4)
DEVICE_TYPE_ALL             :: 0xFFFFFFFF

// cl_device_info
DEVICE_TYPE                             :: 0x1000
DEVICE_VENDOR_ID                        :: 0x1001
DEVICE_MAX_COMPUTE_UNITS                :: 0x1002
DEVICE_MAX_WORK_ITEM_DIMENSIONS         :: 0x1003
DEVICE_MAX_WORK_GROUP_SIZE              :: 0x1004
DEVICE_MAX_WORK_ITEM_SIZES              :: 0x1005
DEVICE_PREFERRED_VECTOR_WIDTH_CHAR      :: 0x1006
DEVICE_PREFERRED_VECTOR_WIDTH_SHORT     :: 0x1007
DEVICE_PREFERRED_VECTOR_WIDTH_INT       :: 0x1008
DEVICE_PREFERRED_VECTOR_WIDTH_LONG      :: 0x1009
DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT     :: 0x100A
DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE    :: 0x100B
DEVICE_MAX_CLOCK_FREQUENCY              :: 0x100C
DEVICE_ADDRESS_BITS                     :: 0x100D
DEVICE_MAX_READ_IMAGE_ARGS              :: 0x100E
DEVICE_MAX_WRITE_IMAGE_ARGS             :: 0x100F
DEVICE_MAX_MEM_ALLOC_SIZE               :: 0x1010
DEVICE_IMAGE2D_MAX_WIDTH                :: 0x1011
DEVICE_IMAGE2D_MAX_HEIGHT               :: 0x1012
DEVICE_IMAGE3D_MAX_WIDTH                :: 0x1013
DEVICE_IMAGE3D_MAX_HEIGHT               :: 0x1014
DEVICE_IMAGE3D_MAX_DEPTH                :: 0x1015
DEVICE_IMAGE_SUPPORT                    :: 0x1016
DEVICE_MAX_PARAMETER_SIZE               :: 0x1017
DEVICE_MAX_SAMPLERS                     :: 0x1018
DEVICE_MEM_BASE_ADDR_ALIGN              :: 0x1019
DEVICE_MIN_DATA_TYPE_ALIGN_SIZE         :: 0x101A
DEVICE_SINGLE_FP_CONFIG                 :: 0x101B
DEVICE_GLOBAL_MEM_CACHE_TYPE            :: 0x101C
DEVICE_GLOBAL_MEM_CACHELINE_SIZE        :: 0x101D
DEVICE_GLOBAL_MEM_CACHE_SIZE            :: 0x101E
DEVICE_GLOBAL_MEM_SIZE                  :: 0x101F
DEVICE_MAX_CONSTANT_BUFFER_SIZE         :: 0x1020
DEVICE_MAX_CONSTANT_ARGS                :: 0x1021
DEVICE_LOCAL_MEM_TYPE                   :: 0x1022
DEVICE_LOCAL_MEM_SIZE                   :: 0x1023
DEVICE_ERROR_CORRECTION_SUPPORT         :: 0x1024
DEVICE_PROFILING_TIMER_RESOLUTION       :: 0x1025
DEVICE_ENDIAN_LITTLE                    :: 0x1026
DEVICE_AVAILABLE                        :: 0x1027
DEVICE_COMPILER_AVAILABLE               :: 0x1028
DEVICE_EXECUTION_CAPABILITIES           :: 0x1029
DEVICE_QUEUE_PROPERTIES                 :: 0x102A
DEVICE_NAME                             :: 0x102B
DEVICE_VENDOR                           :: 0x102C
DRIVER_VERSION                          :: 0x102D
DEVICE_PROFILE                          :: 0x102E
DEVICE_VERSION                          :: 0x102F
DEVICE_EXTENSIONS                       :: 0x1030
DEVICE_PLATFORM                         :: 0x1031
DEVICE_DOUBLE_FP_CONFIG                 :: 0x1032

// Error Codes
SUCCESS                                     :: 0
DEVICE_NOT_FOUND                            :: -1
DEVICE_NOT_AVAILABLE                        :: -2
COMPILER_NOT_AVAILABLE                      :: -3
MEM_OBJECT_ALLOCATION_FAILURE               :: -4
OUT_OF_RESOURCES                            :: -5
OUT_OF_HOST_MEMORY                          :: -6
PROFILING_INFO_NOT_AVAILABLE                :: -7
MEM_COPY_OVERLAP                            :: -8
IMAGE_FORMAT_MISMATCH                       :: -9
IMAGE_FORMAT_NOT_SUPPORTED                  :: -10
BUILD_PROGRAM_FAILURE                       :: -11
MAP_FAILURE                                 :: -12
MISALIGNED_SUB_BUFFER_OFFSET                :: -13
EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST   :: -14
COMPILE_PROGRAM_FAILURE                     :: -15
LINKER_NOT_AVAILABLE                        :: -16
LINK_PROGRAM_FAILURE                        :: -17
DEVICE_PARTITION_FAILED                     :: -18
KERNEL_ARG_INFO_NOT_AVAILABLE               :: -19
INVALID_VALUE                               :: -30
INVALID_DEVICE_TYPE                         :: -31
INVALID_PLATFORM                            :: -32
INVALID_DEVICE                              :: -33
INVALID_CONTEXT                             :: -34
INVALID_QUEUE_PROPERTIES                    :: -35
INVALID_COMMAND_QUEUE                       :: -36
INVALID_HOST_PTR                            :: -37
INVALID_MEM_OBJECT                          :: -38
INVALID_IMAGE_FORMAT_DESCRIPTOR             :: -39
INVALID_IMAGE_SIZE                          :: -40
INVALID_SAMPLER                             :: -41
INVALID_BINARY                              :: -42
INVALID_BUILD_OPTIONS                       :: -43
INVALID_PROGRAM                             :: -44
INVALID_PROGRAM_EXECUTABLE                  :: -45
INVALID_KERNEL_NAME                         :: -46
INVALID_KERNEL_DEFINITION                   :: -47
INVALID_KERNEL                              :: -48
INVALID_ARG_INDEX                           :: -49
INVALID_ARG_VALUE                           :: -50
INVALID_ARG_SIZE                            :: -51
INVALID_KERNEL_ARGS                         :: -52
INVALID_WORK_DIMENSION                      :: -53
INVALID_WORK_GROUP_SIZE                     :: -54
INVALID_WORK_ITEM_SIZE                      :: -55
INVALID_GLOBAL_OFFSET                       :: -56
INVALID_EVENT_WAIT_LIST                     :: -57
INVALID_EVENT                               :: -58
INVALID_OPERATION                           :: -59
INVALID_GL_OBJECT                           :: -60
INVALID_BUFFER_SIZE                         :: -61
INVALID_MIP_LEVEL                           :: -62
INVALID_GLOBAL_WORK_SIZE                    :: -63
INVALID_PROPERTY                            :: -64
INVALID_IMAGE_DESCRIPTOR                    :: -65
INVALID_COMPILER_OPTIONS                    :: -66
INVALID_LINKER_OPTIONS                      :: -67
INVALID_DEVICE_PARTITION_COUNT              :: -68

// cl_mem_flags - bitfield
MEM_READ_WRITE                              :: (1 << 0)
MEM_WRITE_ONLY                              :: (1 << 1)
MEM_READ_ONLY                               :: (1 << 2)
MEM_USE_HOST_PTR                            :: (1 << 3)
MEM_ALLOC_HOST_PTR                          :: (1 << 4)
MEM_COPY_HOST_PTR                           :: (1 << 5)
MEM_HOST_WRITE_ONLY                         :: (1 << 7)
MEM_HOST_READ_ONLY                          :: (1 << 8)
MEM_HOST_NO_ACCESS                          :: (1 << 9)

// cl_kernel_work_group_info
KERNEL_WORK_GROUP_SIZE                      :: 0x11B0
KERNEL_COMPILE_WORK_GROUP_SIZE              :: 0x11B1
KERNEL_LOCAL_MEM_SIZE                       :: 0x11B2
KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE   :: 0x11B3
KERNEL_PRIVATE_MEM_SIZE                     :: 0x11B4
KERNEL_GLOBAL_WORK_SIZE                     :: 0x11B5

// cl_gl
GL_CONTEXT_KHR                              :: 0x2008
EGL_DISPLAY_KHR                             :: 0x2009
GLX_DISPLAY_KHR                             :: 0x200A
WGL_HDC_KHR                                 :: 0x200B
CGL_SHAREGROUP_KHR                          :: 0x200C

// cl_context_properties
CONTEXT_PLATFORM                            :: 0x1084
CONTEXT_INTEROP_USER_SYNC                   :: 0x1085
CONTEXT_PROPERTY_USE_CGL_SHAREGROUP_APPLE   :: 0x10000000
