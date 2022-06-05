#pragma once
#include "panic.h"
#include "types.h"

#include "stdio.h"

#define VX_CREATE_TO_STRING(_TYPE, ...) namespace vx {              \
inline void to_string(_TYPE* PTR, char* BUFFER, usize SIZE) {       \
    __VA_ARGS__;                                                    \
}                                                                   \
};

#define VX_CREATE_TO_STRING_T(_TEMPLATE_DEF, _TYPE, ...) namespace vx { \
_TEMPLATE_DEF                                                           \
inline void to_string(_TYPE* PTR, char* BUFFER, usize SIZE) {           \
    __VA_ARGS__;                                                        \
}                                                                       \
};

VX_CREATE_TO_STRING(u8,  snprintf(BUFFER, SIZE, "%d", *PTR);    )
VX_CREATE_TO_STRING(u16, snprintf(BUFFER, SIZE, "%d", *PTR);    )
VX_CREATE_TO_STRING(u32, snprintf(BUFFER, SIZE, "%d", *PTR);    )
VX_CREATE_TO_STRING(u64, snprintf(BUFFER, SIZE, "%lld", *PTR);  )
VX_CREATE_TO_STRING(i8,  snprintf(BUFFER, SIZE, "%u", *PTR);    )
VX_CREATE_TO_STRING(i16, snprintf(BUFFER, SIZE, "%u", *PTR);    )
VX_CREATE_TO_STRING(i32, snprintf(BUFFER, SIZE, "%u", *PTR);    )
VX_CREATE_TO_STRING(i64, snprintf(BUFFER, SIZE, "%llu", *PTR);  )
VX_CREATE_TO_STRING(f32, snprintf(BUFFER, SIZE, "%f", *PTR);    )
VX_CREATE_TO_STRING(f64, snprintf(BUFFER, SIZE, "%lf", *PTR);   )
VX_CREATE_TO_STRING(bool, snprintf(BUFFER, SIZE, "%d", *PTR);   )