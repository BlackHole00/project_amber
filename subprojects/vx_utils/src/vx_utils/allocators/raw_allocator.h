#pragma once

#include "../mem.h"
#include "../instance.h"

namespace vx {

/**
 * @class RawAllocator - INSTANCE
 * @brief An allocator implementation that calls raw C malloc, realloc and free.
 */
typedef vx::Allocator RawAllocator;
VX_DECLARE_INSTANCE(RawAllocator, RAW_ALLOCATOR_INSTANCE)

/**
 * @brief Initializes the RAW_ALLOCATOR_INSTANCE.
 */
void raw_allocator_init();

/**
 * @brief Deinitializes the RAW_ALLOCATOR_INSTANCE.
 */
void raw_allocator_free();

}
