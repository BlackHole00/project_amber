#pragma once

#include "traits/iterator.h"

#define VX_FOREACH(_VAR_NAME, _CONTAINER, ...) {    \
    auto ITER = ::vx::to_iter(_CONTAINER);          \
    while (!::vx::iter_has_finished(&ITER)) {       \
        auto _VAR_NAME = ::vx::iter_next(&ITER);    \
        __VA_ARGS__;                                \
    }                                               \
}
