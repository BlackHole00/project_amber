#pragma once

#include "types.h"
#include "mem.h"
#include "traits/len.h"
#include "traits/as_ptr.h"
#include "traits/iterator.h"

namespace vx {

/**
 * @class Slice
 * @brief An object that holds an array with its length. Can use the [] operator. It is always intended to be passes as value.
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

/**
 * @brief Creates a new slice from an array.
 * @param array The array.
 */
template <class T, usize LEN>
Slice<T> slice_from_array(T array[LEN]) {
    Slice<T> slice;

    slice.data = array;
    slice.length = LEN;

    return slice;
}

template <class T>
struct SliceIterator {
    Slice<T> slice;
    usize current_idx;
};

};

VX_CREATE_LEN_T(template <class T>, Slice<T>, 
    return VALUE.length;
)

VX_CREATE_AS_PTR_T(template <class T>, Slice<T>, T,
    return VALUE.data;
)

VX_CREATE_TO_ITER_T(template <class T>, Slice<T>, SliceIterator<T>,
    SliceIterator<T> iter;

    iter.slice = VALUE;
    iter.current_idx = 0;

    return iter;
)

VX_CREATE_ITER_NEXT_T(template <class T>, SliceIterator<T>, T,
    VX_ASSERT("Iterator out of bounds!\n", ITER->current_idx < len(ITER->slice));

    ITER->current_idx++;

    return &(ITER->slice[ITER->current_idx - 1]);
)

VX_CREATE_ITER_HAS_FINISHED_T(template <class T>, SliceIterator<T>,
    return ITER->current_idx >= len(ITER->slice);
)
