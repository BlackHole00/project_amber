#pragma once

#include "../types.h"

#define VX_CREATE_LEN(_TYPE, ...) namespace vx {                    \
inline usize len(_TYPE* VALUE) {                                    \
    __VA_ARGS__;                                                    \
}                                                                   \
};

#define VX_CREATE_LEN_T(_TEMPLATE_DEF, _TYPE, ...) namespace vx {   \
_TEMPLATE_DEF                                                       \
inline usize len(_TYPE* VALUE) {                                    \
    __VA_ARGS__;                                                    \
}                                                                   \
};
