#pragma once

#include "panic.h"

#include "traits/as_ptr.h"

namespace vx {

/**
 * @class An object which may or may not contain some data of type T.
 * @implements as_ptr
 */
template <class T>
struct Option {
    bool is_some = false;
    T _data;
};

/**
 * @brief Creates an Option with some data.
 */
template <class T>
constexpr Option<T> option_some(T data) {
    Option<T> option;

    option.is_some = true;
    option._data = data;

    return option;
}

/**
 * @brief Create an empty Option, without data.
 */
template <class T>
constexpr Option<T> option_none() {
    Option<T> option;

    option.is_some = false;

    return option;
}

/**
 * @brief Unwraps an option.
 * @param option An option. If it is not valid, then the program will halt.
 */
template <class T>
T* option_unwrap(Option<T>* option) {
    VX_ASSERT("None value found when unwrapping option!", option->is_some);

    return &(option->_data);
}

/**
 * @brief Unwraps an option.
 * @param option An option. If it is not valid, then the program will halt.
 */
template <class T>
T option_unwrap(Option<T> option) {
    VX_ASSERT("None value found when unwrapping option!", option.is_some);

    return option._data;
}

};

VX_CREATE_AS_PTR_T(template <class T>, Option<T>*, T,
    if (VALUE->is_some) {
        return &VALUE->_data;
    }

    return nullptr;
)

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
