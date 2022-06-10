#pragma once

#include "../types.h"
#include "../slice.h"

#define VX_CREATE_AS_SLICE(_TYPE, _RETURN_TYPE, ...) namespace vx {         \
inline Slice<_RETURN_TYPE> as_slice(_TYPE VALUE) {                          \
    __VA_ARGS__;                                                            \
}                                                                           \
};

#define VX_CREATE_AS_SLICE_T(_TEMPLATE_DEF, _TYPE, _RETURN_TYPE, ...) namespace vx {    \
_TEMPLATE_DEF                                                               \
inline Slice<_RETURN_TYPE> as_slice(_TYPE VALUE) {                          \
    __VA_ARGS__;                                                            \
}                                                                           \
};
