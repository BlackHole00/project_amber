#pragma once
#include "types.h"

#ifndef PI
#define PI 3.14159265359f
#endif

static inline f32 vx_deg_to_rad(f32 deg) {
    return deg * PI / 180.0f;
}

static inline f32 vx_rad_to_deg(f32 rad) {
    return rad * 180.0f / PI;
}
