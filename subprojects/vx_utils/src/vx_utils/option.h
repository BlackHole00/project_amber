#pragma once

#include "panic.h"

namespace vx {

template <class T>
struct Option {
    bool is_some = false;
    T data;
};

template <class T>
constexpr Option<T> option_some(T data) {
    Option<T> option;

    option.is_some = true;
    option.data = data;

    return option;
}

template <class T>
constexpr Option<T> option_none() {
    Option<T> option;

    option.is_some = false;

    return option;
}

template <class T>
T* option_unwrap(Option<T>* option) {
    VX_ASSERT("None value found when unwrapping option!", option->is_some);

    return &(option->data);
}

template <class T>
T option_unwrap(Option<T> option) {
    VX_ASSERT("None value found when unwrapping option!", option.is_some);

    return option.data;
}

template <class T>
T* option_as_ptr(Option<T>* option) {
    if (option->is_some) {
        return &option->data;
    }

    return nullptr;
}

};

///////////////////////////////////////////////////////////////////////////////////////////////////
/*  vx_Option example:
*
*       //  If the number is negative we do not return anything
*       vx::Option<f32> safe_sqrt(f32 n) {
*           if (n < 0) {
*               return vx::option_none<f32>();
*           }
*
*           return vx::option_some(sqrtf(n));
*       }
*
*       int main() {
*           printf("%f", vx::option_unwrap(safe_sqrt(-40.0)));
*
*           return 0;
*       }
*/
