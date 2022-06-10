#pragma once

#include "types.h"
#include "mem.h"
#include "traits/len.h"

namespace vx {

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

template <class T, usize LEN>
Slice<T> slice_new(T array[LEN]) {
    Slice<T> slice;

    slice.data = array;
    slice.length = VX_ARRAY_ELEMENT_COUNT(array);

    return slice;
}

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
