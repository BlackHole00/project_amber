#pragma once
#include "vx_template.h"
#include "vx_types.h"
#include <stdbool.h>
#include "vx_panic.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
#define _VX_OPTION_ELEM(T) typedef struct {                                                         \
    bool is_some;                                                                                   \
    T data;                                                                                         \
} VX_TEMPLATE_NAME(T, vx_Option);
#define _VX_OPTION_SOME_INL(T) static inline VX_TEMPLATE_NAME(T, vx_Option) VX_TEMPLATE_NAME(T, vx_option_some)(T value) {\
    VX_TEMPLATE_NAME(T, vx_Option) option;                                                          \
    option.is_some = true;                                                                          \
    option.data = value;                                                                            \
    return option;                                                                                  \
}
#define _VX_OPTION_NONE_INL(T) static inline VX_TEMPLATE_NAME(T, vx_Option) VX_TEMPLATE_NAME(T, vx_option_none)() {\
    VX_TEMPLATE_NAME(T, vx_Option) option;                                                          \
    option.is_some = false;                                                                         \
    return option;                                                                                  \
}
#define _VX_OPTION_UNWRAP_INL(T) static inline T VX_TEMPLATE_NAME(T, vx_option_unwrap)(VX_TEMPLATE_NAME(T, vx_Option) option) {\
    VX_ASSERT("None value found when unwrapping option!", option.is_some);                          \
    return option.data;                                                                             \
}

#define _VX_OPTION_CREATE_FOR_TYPE(_T) VX_TEMPLATE_ELEM(_T, _VX_OPTION_ELEM)                        \
VX_TEMPLATE_INL(_T, _VX_OPTION_SOME_INL)                                                            \
VX_TEMPLATE_INL(_T, _VX_OPTION_NONE_INL)                                                            \
VX_TEMPLATE_INL(_T, _VX_OPTION_UNWRAP_INL)

///////////////////////////////////////////////////////////////////////////////////////////////////
_VX_OPTION_CREATE_FOR_TYPE(u8)
_VX_OPTION_CREATE_FOR_TYPE(u16)
_VX_OPTION_CREATE_FOR_TYPE(u32)
_VX_OPTION_CREATE_FOR_TYPE(u64)
_VX_OPTION_CREATE_FOR_TYPE(i8)
_VX_OPTION_CREATE_FOR_TYPE(i16)
_VX_OPTION_CREATE_FOR_TYPE(i32)
_VX_OPTION_CREATE_FOR_TYPE(i64)
_VX_OPTION_CREATE_FOR_TYPE(f32)
_VX_OPTION_CREATE_FOR_TYPE(f64)

///////////////////////////////////////////////////////////////////////////////////////////////////
/*  vx_Option example:
*
*       //  If the number is negative we do not return anything
*       VX_T(f32, vx_Option) safe_sqrt(float n) {
*           if (n < 0) {
*               return VX_T(f32, vx_option_none)();
*           }
*
*           return VX_T(f32, vx_option_some)(sqrtf(n));
*       }
*
*       int main() {
*           printf("%f", VX_T(f32, vx_option_unwrap)(safe_sqrt(-40)));
*
*           return 0;
*       }
*/
