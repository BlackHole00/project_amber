#pragma once
#include <memory.h>

#include "types.h"
#include "functions.h"
#include "instance.h"

#define VX_EMPTY_STRUCT u8 __empty_field;

#define VX_ARRAY_ELEMENT_COUNT(_ARR) (sizeof((_ARR)) / sizeof(*(_ARR)))

namespace vx {

template <class T>
struct Vector;

struct Allocator {
    void* allocator_data;
    VX_CALLBACK(void*,  alloc,      usize size              );
    VX_CALLBACK(void*,  realloc,    void* ptr, usize size   );
    VX_CALLBACK(void,   free,       void* ptr               );
    VX_CALLBACK(void,   memory_report                       );
};


typedef Vector<Allocator*> AllocatorStack;
VX_DECLARE_INSTANCE(AllocatorStack, ALLOCATOR_STACK_INSTANCE)

void allocator_stack_init();
void allocator_stack_free();
void allocator_stack_push_allocator(Allocator* allocator);
void allocator_stack_pop_allocator();
Allocator* allocator_stack_get_current_allocator();

#define VX_PUSH_ALLOCATOR(_ALLOCATOR)   vx::allocator_stack_push_allocator(_ALLOCATOR)
#define VX_POP_ALLOCATOR()              vx::allocator_stack_pop_allocator()
#define VX_GET_ALLOCATOR()              vx::allocator_stack_get_current_allocator()


template <class T>
T* alloc(usize elem_num, Allocator* allocator = nullptr) {
    if (allocator == nullptr) {
        allocator = VX_GET_ALLOCATOR();
    }

    return (T*)allocator->alloc(elem_num * sizeof(T));
}

template <class T>
T* realloc(T* ptr, usize elem_num, Allocator* allocator = nullptr) {
    if (allocator == nullptr) {
        allocator = VX_GET_ALLOCATOR();
    }

    return (T*)allocator->realloc(ptr, elem_num * sizeof(T));
}

template <class T>
void free(T* ptr, Allocator* allocator = nullptr) {
    if (allocator == nullptr) {
        allocator = VX_GET_ALLOCATOR();
    }

    allocator->free(ptr);
}

};
