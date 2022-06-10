#pragma once

#include "mem.h"
#include "option.h"
#include "mem.h"
#include "traits/clone.h"
#include "traits/len.h"
#include "traits/as_slice.h"
#include "traits/as_ptr.h"
#include <string.h>

// TODO: Actually implement this formula.
#define VX_VECTOR_GROW_FORMULA(x) (2*(x) + 8)

namespace vx {

/**
 * @class Vector<T>
 * @brief A dynamic-growing vector.
 * @implements clone, len, as_slice, as_ptr.
 * @param T The type of the items being stored.
 */
template <class T>
struct Vector {
    T* data;
    usize length;       /* The number of items inserted in the vector. */

    usize _mem_length;  /* The total allocated items in the heap. */
    Allocator* _allocator;

    T operator[](int idx) const {
        return data[idx];
    }

    T& operator[](int idx) {
        return data[idx];
    }
};

/**
 * @brief Creates a new Vector.
 * @param initial_size The initial number of elements allocated in the vector. All these items are zero-initilized.
 * @param allocator A pointer to an allocator. If nullptr, the current allocator from the AllocatorStack will be used.
 */
template <class T>
Vector<T> vector_new(usize initial_size = 0, Allocator* allocator = nullptr) {
    VX_VALIDATE_ALLOCATOR(allocator);
    
    Vector<T> vector;

    vector.length = initial_size;
    vector._mem_length = initial_size;
    vector._allocator = allocator;

    vector.data = vx::alloc<T>(initial_size, allocator);
    if (initial_size != 0) {
        memset((void*)vector.data, 0, initial_size * sizeof(T));
    }

    return vector;
}

/**
 * @brief Frees a Vector.
 */
template <class T>
void vector_free(Vector<T>* vector) {
    VX_NULL_ASSERT(vector);

    vx::free(vector->data, vector->_allocator);
    vector->_mem_length = 0;
    vector->length = 0;
    vector->data = nullptr;
}

/**
 * @brief Clears all the content of a vector. (Not all memory will be freed).
 */
template <class T>
void vector_clear(Vector<T>* vector) {
    VX_NULL_ASSERT(vector);

    /* Free half of the memory. */
    vector->data = vx::realloc(vector->data, vector->_mem_length / 2, vector->_allocator);
    vector->_mem_length /= 2;
    vector->length = 0;
}

/**
 * @brief Pushes an item into the back of the vector.
 * @param vector A pointer to the vector.
 * @param data The item.
 */
template <class T>
void vector_push(Vector<T>* vector, T data) {
    VX_NULL_ASSERT(vector);

    /* If the vector is full, then enlarge it. */
    if (vector->length >= vector->_mem_length) {
        vector->_mem_length = (vector->_mem_length == 0) ? 1 : vector->_mem_length * 2;
        vector->data = vx::realloc<T>(vector->data, vector->_mem_length, vector->_allocator);
    }

    /* Push the new value. */
    (*vector)[vector->length] = data;
    vector->length++;
}

/**
 * @brief Removes an item from the back of the vector
 * @return Returns OptionSome if an item could be found or OptionNone if the vector was empty.
 */
template <class T>
vx::Option<T> vector_pop(Vector<T>* vector) {
    VX_NULL_ASSERT(vector);

    if (vector->length > 0) {
        T top = (*vector)[vector->length - 1];
        vector->length--;

        /* Resize the vector if needed. */
        if (vector->length <= (vector->_mem_length / 2)) {
            vector->_mem_length /= 2;
            vector->data = vx::realloc<T>(vector->data, vector->_mem_length, vector->_allocator);
        }

        return vx::option_some(top);
    }
    return vx::option_none<T>();
}

/**
 * @brief Returns a pointer to the top element of the vector.
 * @return Returns nullptr if the vector is empty.
 */
template <class T>
T* vector_top(Vector<T>* vector) {
    VX_NULL_CHECK(vector);

    if (vector->length > 0) {
        return &(*vector)[vector->length - 1];
    }
    return nullptr;
}

/**
 * @brief Returns a pointer to a element of the vector.
 * @return Returns nullptr if the item does not exist.
 */
template <class T>
T* vector_get(Vector<T>* vector, usize index) {
    VX_NULL_CHECK(vector);

    if (index < vector->length) {
        return &(*vector)[index];
    }
    return nullptr;
}

/**
 * @brief Inserts an element in the desired position. O(N) complexity.
 */
template <class T>
void vector_insert(Vector<T>* vector, T data, usize index) {
    VX_NULL_ASSERT(vector);

    vector_push(vector, data);
    for (u32 i = (vector->length - 1); i > index; i--) {
        (*vector)[i] = (*vector)[i - 1];
    }
    (*vector)[index] = data;
}

/**
 * @brief Removes an element at the desired position. O(N) complexity.
 * @return Returns the element removed if it was found or OptionNone if it did no exist.
 */
template <class T>
vx::Option<T> vector_remove(Vector<T>* vector, usize index) {
    if (index >= vector->length || index < 0) {
        return vx::option_none<T>();
    }

    T value = (*vector)[index];
    for (u32 i = index; i < vector->length - 1; i++) {
        (*vector)[i] = (*vector)[i + 1];
    }
    vector_pop(vector);

    return vx::option_some(value);
}

/**
 * @brief Resizes the vector.
 */
template <class T>
void vector_resize(Vector<T>* vector, usize new_size) {
    vector->data = vx::realloc<T>(vector->data, new_size, vector->_allocator);

    vector->length = new_size;
    vector->_mem_length = new_size;
}

};

VX_CREATE_CLONE_T(template<class T>, Vector<T>,
    vector_clear(DEST); 
    for (usize i = 0; i < SOURCE->length; i++) {
        vector_push<T>(DEST, (*SOURCE)[i]);
    }
)

VX_CREATE_LEN_T(template <class T>, Vector<T>*,
    return VALUE->length;
)

VX_CREATE_AS_SLICE_T(template <class T>, Vector<T>*, T,
    return slice_new(VALUE->data, VALUE->length);
)

VX_CREATE_AS_PTR_T(template <class T>, Vector<T>*, T,
    return slice_new(VALUE->data, VALUE->length);
)

/* EXAMPLE:
    int main() {
        vx::allocator_stack_init();
        VX_DEFER(vx::allocator_stack_free());

        vx::Vector<f32> vec = vx::vector_new<f32>();
        vx::Vector<f32> vec2 = vx::vector_new<f32>();
        VX_DEFER(vx::vector_free<f32>(&vec));
        VX_DEFER(vx::vector_free<f32>(&vec2));

        vx::vector_push<f32>(&vec, 10);
        vx::vector_push<f32>(&vec, 20);
        vx::vector_push<f32>(&vec, 30);
        vx::vector_push<f32>(&vec, 40);

        vec2 = vec; // This is a shallow copy. Use with attention.
        vx::clone(&vec, &vec2); // This is a deep copy.

        vx::vector_remove<f32>(&vec2, 2);
        vx::vector_insert<f32>(&vec2, 35, 2);

        vx::Slice<f32> vec1_slice = vx::as_slice(&vec1);
        for (usize i = 0; i < len(vec1_slice); i++) {
            printf("%lld: %f\n", i, vec1_slice[i]);
        }

        vx::Slice<f32> vec2_slice = vx::as_slice(&vec2);
        for (usize i = 0; i < len(vec2_slice); i++) {
            printf("%lld: %f\n", i, vec2_slice[i]);
        }

        return 0;
    }
*/
