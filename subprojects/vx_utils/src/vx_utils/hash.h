#pragma once
#include "template.h"
#include "types.h"
#include <string.h>

#define VX_CREATE_HASH(_TYPE, ...) namespace vx {                   \
inline u64 hash(_TYPE VALUE) {                                      \
    __VA_ARGS__;                                                    \
}                                                                   \
};

#define VX_CREATE_HASH_T(_TEMPLATE_DEF, _TYPE, ...) namespace vx {  \
_TEMPLATE_DEF                                                       \
inline u64 hash(_TYPE VALUE) {                                      \
    __VA_ARGS__;                                                    \
}                                                                   \
};

VX_CREATE_HASH(const char*,
    u64 hash = 525201411107845655ull;

    for ( ; *VALUE; ++VALUE) {
        hash ^= *VALUE;
        hash *= 0x5bd1e9955bd1e995;
        hash ^= hash >> 47;
    }

    return hash;
)
