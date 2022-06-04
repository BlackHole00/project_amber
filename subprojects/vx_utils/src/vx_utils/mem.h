#pragma once
#include <memory.h>
#include "types.h"

#define VX_EMPTY_STRUCT u8 __empty_field;

#define VX_ARRAY_ELEMENT_COUNT(_ARR) (sizeof((_ARR)) / sizeof(*(_ARR)))

namespace vx {

void* raw_alloc(usize);
void* raw_realloc(void*, usize);
void raw_free(void*);
void memory_print_state();

template <class T>
T* alloc(usize elem_num) {
    return (T*)vx::raw_alloc(elem_num * sizeof(T));
}

template <class T>
T* realloc(T* ptr, usize elem_num) {
    return (T*)vx::raw_realloc(ptr, elem_num * sizeof(T));
}

template <class T>
void free(T* ptr) {
    raw_free((T*)ptr);
}

};
