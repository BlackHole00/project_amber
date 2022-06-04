#pragma once

#define VX_CREATE_CLONE(_TYPE, ...) namespace vx {              \
inline void clone(_TYPE* source, _TYPE* dest) {                 \
    __VA_ARGS__                                                 \
}                                                               \
};

#define VX_CREATE_CLONE_T(_TEMPLATE_DEF, _TYPE, ...) namespace vx { \
_TEMPLATE_DEF                                                       \
inline void clone(_TYPE* source, _TYPE* dest) {                     \
    __VA_ARGS__                                                     \
}                                                                   \
};
