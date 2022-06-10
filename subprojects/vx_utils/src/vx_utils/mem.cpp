#include "mem.h"

#include "panic.h"
#include "log.h"
#include "vector.h"
#include "allocators/raw_allocator.h"

namespace vx {

VX_CREATE_INSTANCE(AllocatorStack, ALLOCATOR_STACK_INSTANCE)

void allocator_stack_init() {
    if (!RAW_ALLOCATOR_INSTANCE_VALID) {
        raw_allocator_init();
    }

    ALLOCATOR_STACK_INSTANCE = vector_new<Allocator*>(1, &RAW_ALLOCATOR_INSTANCE);

    ALLOCATOR_STACK_INSTANCE[0] = &RAW_ALLOCATOR_INSTANCE;

    ALLOCATOR_STACK_INSTANCE_VALID = true;
}

void allocator_stack_free() {
    vector_free(&ALLOCATOR_STACK_INSTANCE);

    ALLOCATOR_STACK_INSTANCE_VALID = false;
}

void allocator_stack_push_allocator(Allocator* allocator) {
    VX_ASSERT("The stack instance has not been initialized yet!", ALLOCATOR_STACK_INSTANCE_VALID);

    vector_push(&ALLOCATOR_STACK_INSTANCE, allocator);
}

void allocator_stack_pop_allocator() {
    VX_ASSERT("The stack instance has not been initialized yet!", ALLOCATOR_STACK_INSTANCE_VALID);

    if (ALLOCATOR_STACK_INSTANCE.length <= 1) {
        log(LogMessageLevel::WARN, "The user is trying to pop the base raw allocator in the allocator_stack. Ignoring!");
        return;
    }

    vector_pop(&ALLOCATOR_STACK_INSTANCE);
}

Allocator* allocator_stack_get_current_allocator() {
    VX_ASSERT("The stack instance has not been initialized yet!", ALLOCATOR_STACK_INSTANCE_VALID);

    return *vector_top(&ALLOCATOR_STACK_INSTANCE);
}

};

