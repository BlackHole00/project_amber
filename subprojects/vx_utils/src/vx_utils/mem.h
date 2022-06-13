#pragma once
#include <memory.h>

#include "types.h"
#include "functions.h"
#include "instance.h"

/** @brief Use inside a struct to emphatize that it's empty. */
#define VX_EMPTY_STRUCT u8 __empty_field;

/** @brief Get the length of a standard C array (not a pointer!). */
#define VX_ARRAY_ELEMENT_COUNT(_ARR) (sizeof((_ARR)) / sizeof(*(_ARR)))

namespace vx {

template <class T>
struct Vector;

/**
 * @class Allocator
 * @brief Provides the functions for allocating, deallocating and freeing memory.
 */
struct Allocator {
    void* allocator_data;
    VX_CALLBACK(void*,  alloc,      usize size              );
    VX_CALLBACK(void*,  realloc,    void* ptr, usize size   );
    VX_CALLBACK(void,   free,       void* ptr               );
    VX_CALLBACK(void,   memory_report                       );
};

/**
 * The memory management in vx_utils uses a Allocator Stack.
 * All the data structures in vx_utils require an allocator provided as a constructor parameter.
 * If not specified an allocator will be acquired from the allocator stack.
 *
 * It is possibile to temporarly push an allocator and then pop it if a custom allocator is needed.
 * By default the stack allocator will use a raw system allocator. It cannot be removed.
 *
 * @class AllocatorStack - INSTANCE
 * @brief A stack used to manage the allocators.
 */
typedef Vector<Allocator*> AllocatorStack;
VX_DECLARE_INSTANCE(AllocatorStack, ALLOCATOR_STACK_INSTANCE)

/** @brief Initialises the allocator stack. */
void allocator_stack_init();
/** @brief Frees the allocator stack. */
void allocator_stack_free();
/** @brief Pushes a custom allocator in the stack. It will be used until it will be popped. */
void allocator_stack_push_allocator(Allocator* allocator);
/** @brief Pop the current allocator. */
void allocator_stack_pop_allocator();
/** @brief Returns the current allocator. */
Allocator* allocator_stack_get_current_allocator();

#define VX_PUSH_ALLOCATOR(_ALLOCATOR)   vx::allocator_stack_push_allocator(_ALLOCATOR)
#define VX_POP_ALLOCATOR()              vx::allocator_stack_pop_allocator()
#define VX_GET_ALLOCATOR()              vx::allocator_stack_get_current_allocator()

/** @brief Validates an allocator. 
 *  @param _ALLOCATOR_PTR A variable containing a pointer to an allocator. If nullptr it will be set the the current allocator from the AllocatorStack.
*/
#define VX_VALIDATE_ALLOCATOR(_ALLOCATOR_PTR) (_ALLOCATOR_PTR) = ((_ALLOCATOR_PTR) != nullptr ? (_ALLOCATOR_PTR) : VX_GET_ALLOCATOR())

/**
 * @brief Allocates N items of type T.
 * @param elem_num The number of items.
 * @param allocator The desired allocator. If nullptr, the current allocator from the AllocatorStack will be used.
 */
template <class T>
T* alloc(usize elem_num, Allocator* allocator = nullptr) {
    VX_VALIDATE_ALLOCATOR(allocator);

    return (T*)allocator->alloc(elem_num * sizeof(T));
}

/**
 * @brief Reallocates N items of type T.
 * @param ptr The pointer to the data to be reallocated.
 * @param elem_num The new number of items.
 * @param allocator The desired allocator. Must be the same used for the initial allocation! If nullptr, the current allocator from the AllocatorStack will be used.
 */
template <class T>
T* realloc(T* ptr, usize elem_num, Allocator* allocator = nullptr) {
    VX_VALIDATE_ALLOCATOR(allocator);

    return (T*)allocator->realloc(ptr, elem_num * sizeof(T));
}

/**
 * @brief Frees memory previously allocated with free or realloc.
 * @param ptr The pointer to the data to be freed.
 * @param allocator The desired allocator. Must be the same used for the initial allocation! If nullptr, the current allocator from the AllocatorStack will be used.
 */
template <class T>
void free(T* ptr, Allocator* allocator = nullptr) {
    VX_VALIDATE_ALLOCATOR(allocator);

    allocator->free(ptr);
}

};
