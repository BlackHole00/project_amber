#pragma once
#include "panic.h"
#include "types.h"

#define VX_CREATE_TO_STRING(_TYPE, ...) namespace vx {              \
inline void to_string(_TYPE* ptr, char* buffer, usize size) {       \
    __VA_ARGS__                                                     \
}                                                                   \
};

#define VX_CREATE_TO_STRING_T(_TEMPLATE_DEF, _TYPE, ...) namespace vx { \
_TEMPLATE_DEF                                                           \
inline void to_string(_TYPE* ptr, char* buffer, usize size) {           \
    __VA_ARGS__                                                         \
}                                                                       \
};

VX_CREATE_TO_STRING(u8,  snprintf(buffer, size, "%d", *ptr);    )
VX_CREATE_TO_STRING(u16, snprintf(buffer, size, "%d", *ptr);    )
VX_CREATE_TO_STRING(u32, snprintf(buffer, size, "%d", *ptr);    )
VX_CREATE_TO_STRING(u64, snprintf(buffer, size, "%lld", *ptr);  )
VX_CREATE_TO_STRING(i8,  snprintf(buffer, size, "%u", *ptr);    )
VX_CREATE_TO_STRING(i16, snprintf(buffer, size, "%u", *ptr);    )
VX_CREATE_TO_STRING(i32, snprintf(buffer, size, "%u", *ptr);    )
VX_CREATE_TO_STRING(i64, snprintf(buffer, size, "%llu", *ptr);  )
VX_CREATE_TO_STRING(f32, snprintf(buffer, size, "%f", *ptr);    )
VX_CREATE_TO_STRING(f64, snprintf(buffer, size, "%lf", *ptr);   )
VX_CREATE_TO_STRING(bool, snprintf(buffer, size, "%d", *ptr);   )