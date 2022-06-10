#pragma once

#include "types.h"
#include "mem.h"
#include "traits/len.h"
#include "traits/as_ptr.h"

namespace vx {

/**
 * @class Slice
 * @brief An object that holds an array with its length. Can use the [] operator.
 * @implements len, as_ptr
 */
template <class T>
struct Slice {
    T* data;
    usize length;

    T operator[](usize idx) const {
        return this->data[idx];
    }

    T& operator[](usize idx) {
        return this->data[idx];
    }

    operator T*() {
        return data;
    }
};

/**
 * @brief Creates a new slice.
 * @param data The pointer to the first element of the array.
 * @param length The number of elements in the array.
 */
template <class T>
Slice<T> slice_new(T* data, usize length) {
    Slice<T> slice;

    slice.data = data;
    slice.length = length;

    return slice;
}

};

VX_CREATE_LEN_T(template <class T>, Slice<T>, 
    return VALUE.length;
)

VX_CREATE_AS_PTR_T(template <class T>, Slice<T>, T,
    return VALUE.data;
)
