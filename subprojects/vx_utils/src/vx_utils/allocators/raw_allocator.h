#pragma once

#include "../mem.h"
#include "../instance.h"

namespace vx {

typedef vx::Allocator RawAllocator;
VX_DECLARE_INSTANCE(RawAllocator, RAW_ALLOCATOR_INSTANCE)

void raw_allocator_init();
void raw_allocator_free();

}
