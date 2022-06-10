#pragma once

#include "mem.h"
#include "option.h"
#include "mem.h"
#include "traits/clone.h"
#include "traits/len.h"
#include "traits/as_slice.h"
#include <string.h>

// TODO: Actually implement this formula.
#define VX_VECTOR_GROW_FORMULA(x) (2*(x) + 8)

namespace vx {

template <class T>
struct Vector {
    T* data;
    usize length;
    usize _mem_length;

    Allocator* _allocator;

    T operator[](int idx) const {
        return data[idx];
    }

    T& operator[](int idx) {
        return data[idx];
    }
};

template <class T>
Vector<T> vector_new(usize initial_size = 0, Allocator* allocator = nullptr) {
    Vector<T> vector;

    vector.length = initial_size;
    vector._mem_length = initial_size;

    if (allocator == nullptr) {
        allocator = VX_GET_ALLOCATOR();
    }
    vector._allocator = allocator;

    vector.data = vx::alloc<T>(initial_size, allocator);

    return vector;
}

template <class T>
void vector_free(Vector<T>* vector) {
    VX_NULL_ASSERT(vector);

    vx::free(vector->data, vector->_allocator);
    vector->_mem_length = 0;
    vector->length = 0;
    vector->data = nullptr;
}

template <class T>
void vector_clear(Vector<T>* vector) {
    vector->data = vx::realloc(vector->data, vector->_mem_length / 2, vector->_allocator);
    vector->_mem_length /= 2;
    vector->length = 0;
}

template <class T>
void vector_push(Vector<T>* vector, T data) {
    VX_NULL_ASSERT(vector);

    /* If the vector is full, then enlarge it.*/
    if (vector->length >= vector->_mem_length) {
        vector->_mem_length = (vector->_mem_length == 0) ? 1 : vector->_mem_length * 2;
        vector->data = vx::realloc<T>(vector->data, vector->_mem_length, vector->_allocator);
    }

    /* Push the new value*/
    (*vector)[vector->length] = data;
    vector->length++;
}

template <class T>
vx::Option<T> vector_pop(Vector<T>* vector) {
    VX_NULL_ASSERT(vector);

    if (vector->length > 0) {
        T top = (*vector)[vector->length - 1];
        vector->length--;

        if (vector->length <= (vector->_mem_length / 2)) {
            vector->_mem_length /= 2;
            vector->data = vx::realloc<T>(vector->data, vector->_mem_length, vector->_allocator);
        }

        return vx::option_some(top);
    }
    return vx::option_none<T>();
}

template <class T>
T* vector_top(Vector<T>* vector) {
    VX_NULL_CHECK(vector);

    if (vector->length > 0) {
        return &(*vector)[vector->length - 1];
    }
    return nullptr;
}

template <class T>
T* vector_get(Vector<T>* vector, usize index) {
    VX_NULL_CHECK(vector);

    if (index < vector->length) {
        return &(*vector)[index];
    }
    return nullptr;
}

template <class T>
void vector_insert(Vector<T>* vector, T data, usize index) {
    VX_NULL_ASSERT(vector);

    vector_push(vector, data);
    for (u32 i = (vector->length - 1); i > index; i--) {
        (*vector)[i] = (*vector)[i - 1];
    }
    (*vector)[index] = data;
}

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
