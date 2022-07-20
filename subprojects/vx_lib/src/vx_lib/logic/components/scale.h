#pragma once

#include <vx_utils/types.h>
#include "helpers/vector_builder.h"

namespace vx {

VX_BUILD_VEC3(f32, Scale)

inline Scale scale_new(f32 x, f32 y, f32 z) {
    return Scale { x, y, z };
}

inline void to_matrix(const Scale* s, f32* matrix) {
    bx::mtxScale(matrix, s->x, s->y, s->z);
}

};

#include "helpers/vector_builder_undef.h"
