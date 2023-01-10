package OpenCL

import "core:c"

raw_str         :: [^]u8
bitfield        :: distinct c.uint64_t

device_type                 :: distinct bitfield
mem_flags                   :: distinct bitfield
device_info                 :: distinct u32
kernel_work_group_info      :: distinct u32
event_info                  :: distinct u32
context_properties          :: distinct c.intptr_t
command_queue_properties    :: distinct bitfield

event           :: distinct rawptr
mem             :: distinct rawptr
kernel          :: distinct rawptr
program         :: distinct rawptr
command_queue   :: distinct rawptr
cl_context      :: distinct rawptr
platform_id     :: distinct rawptr
device_id       :: distinct rawptr