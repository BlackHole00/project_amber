#pragma once

#include "../types.h"

#define VX_CREATE_AS_PTR(_TYPE, _RETURN_TYPE, ...) namespace vx {           \
inline _RETURN_TYPE* as_ptr(_TYPE VALUE) {                                  \
    __VA_ARGS__;                                                            \
}                                                                           \
};

#define VX_CREATE_AS_PTR_T(_TEMPLATE_DEF, _TYPE, _RETURN_TYPE, ...) namespace vx {    \
_TEMPLATE_DEF                                                               \
inline _RETURN_TYPE* as_ptr(_TYPE VALUE) {                                  \
    __VA_ARGS__;                                                            \
}                                                                           \
};
