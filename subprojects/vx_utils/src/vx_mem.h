#pragma once
#include <memory.h>
#include "vx_types.h"

#define VX_ARRAY_ELEMENT_COUNT(_ARR) (sizeof((_ARR)) / sizeof(*(_ARR)))

void* vx_smalloc(usize);
void* vx_srealloc(void*, usize);
void vx_free(void*);
void vx_memory_print_state();
