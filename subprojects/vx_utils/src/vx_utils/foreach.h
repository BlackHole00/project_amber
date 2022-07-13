#pragma once

#include "traits/iterator.h"

#define VX_FOREACH(_VAR_NAME, _CONTAINER, ...) {    \
    auto ITER = ::vx::to_iter(_CONTAINER);          \
    while (!::vx::iter_has_finished(&ITER)) {       \
        auto _VAR_NAME = ::vx::iter_next(&ITER);    \
        __VA_ARGS__;                                \
    }                                               \
}

#define VX_FOREACH_ITER(_VAR_NAME, _ITER, ...) {    \
    while (!::vx::iter_has_finished(_ITER)) {       \
        auto _VAR_NAME = ::vx::iter_next(_ITER);    \
        __VA_ARGS__;                                \
    }                                               \
}
