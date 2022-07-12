#pragma once

#define VX_CREATE_TO_ITER(_TYPE, _ITER_TYPE, ...) namespace vx {            \
inline _ITER_TYPE to_iter(_TYPE VALUE) {                                    \
    __VA_ARGS__;                                                            \
}                                                                           \
};

#define VX_CREATE_TO_ITER_T(_TEMPLATE_DEF, _TYPE, _ITER_TYPE, ...) namespace vx {    \
_TEMPLATE_DEF                                                               \
inline _ITER_TYPE to_iter(_TYPE VALUE) {                                    \
    __VA_ARGS__;                                                            \
}                                                                           \
};

#define VX_CREATE_ITER_NEXT(_TYPE, _RETURN_TYPE, ...) namespace vx {        \
inline _RETURN_TYPE* iter_next(_TYPE* ITER) {                               \
    __VA_ARGS__;                                                            \
}                                                                           \
};

#define VX_CREATE_ITER_NEXT_T(_TEMPLATE_DEF, _TYPE, _RETURN_TYPE, ...) namespace vx {    \
_TEMPLATE_DEF                                                               \
inline _RETURN_TYPE* iter_next(_TYPE* ITER) {                               \
    __VA_ARGS__;                                                            \
}                                                                           \
};

#define VX_CREATE_ITER_HAS_FINISHED(_TYPE, ...) namespace vx {              \
inline bool iter_has_finished(_TYPE* ITER) {                                \
    __VA_ARGS__;                                                            \
}                                                                           \
};

#define VX_CREATE_ITER_HAS_FINISHED_T(_TEMPLATE_DEF, _TYPE, ...) namespace vx {    \
_TEMPLATE_DEF                                                               \
inline bool iter_has_finished(_TYPE* ITER) {                                \
    __VA_ARGS__;                                                            \
}                                                                           \
};
