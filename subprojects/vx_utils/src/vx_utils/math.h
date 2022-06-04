#pragma once
#include "types.h"

#ifndef PI
#define PI 3.14159265359f
#endif

namespace vx {

static inline f32 deg_to_rad(f32 deg) {
    return deg * PI / 180.0f;
}

static inline f32 rad_to_deg(f32 rad) {
    return rad * 180.0f / PI;
}

};
