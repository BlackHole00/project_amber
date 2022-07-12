#include "raw_allocator.h"

#include <cstdio>
#include <cstdlib>

#include "../panic.h"

namespace vx {

VX_CREATE_INSTANCE(RawAllocator, RAW_ALLOCATOR_INSTANCE)

/* TODO: Make atomic. */
static u32 allocation_number = 0;
static u32 deallocation_number = 0;
static u32 reallocation_number = 0;

static void* raw_alloc(usize size) {
    void* ptr = std::malloc(size);
    VX_ASSERT("Could not allocate memory!", ptr != 0 || size == 0);

    if (ptr != NULL) {
        allocation_number++;
    }

    return ptr;
}

static void* raw_realloc(void* mem_adr, usize size) {
    void* ptr = std::realloc(mem_adr, size);
    VX_ASSERT("Could not reallocate memory!", ptr != 0 || size == 0);

    reallocation_number++;

    return ptr;
}

static void raw_free(void* ptr) {
    if (ptr != NULL) {
        std::free(ptr);

        deallocation_number++;
    }
}

static void memory_print_state() {
    printf("\n---[Memory state]---\n");
    printf("ALLOCATIONS: %d\n", allocation_number);
    printf("DEALLOCATIONS: %d\n", deallocation_number);
    printf("REALLOCATIONS: %d\n", reallocation_number);
    printf("\nThere are %d blocks to free!\n", allocation_number - deallocation_number);

    if (ALLOCATOR_STACK_INSTANCE_VALID) {
        printf("\t(Note: 1 block is used by the allocator stack. Make sure to call vx::allocator_stack_free() before the program ends.)\n");
    }

    printf("--------------------\n");
}

void raw_allocator_init() {
    RAW_ALLOCATOR_INSTANCE.alloc = raw_alloc;
    RAW_ALLOCATOR_INSTANCE.realloc = raw_realloc;
    RAW_ALLOCATOR_INSTANCE.free = raw_free;
    RAW_ALLOCATOR_INSTANCE.memory_report = memory_print_state;
    RAW_ALLOCATOR_INSTANCE.allocator_data = nullptr;

    RAW_ALLOCATOR_INSTANCE_VALID = true;
}

void raw_allocator_free() {
    RAW_ALLOCATOR_INSTANCE_VALID = false;
}

}