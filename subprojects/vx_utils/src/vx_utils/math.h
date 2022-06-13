#pragma once
#include "types.h"

#ifdef PI
#define VX_PI PI
#else
#define VX_PI 3.14159265359f
#endif

namespace vx {

/** @brief Converts an angle from degrees to radiants. */
static inline f32 deg_to_rad(f32 deg) {
    return deg * VX_PI / 180.0f;
}

/** @brief Converts an angle from radiants to degrees. */
static inline f32 rad_to_deg(f32 rad) {
    return rad * 180.0f / VX_PI;
}

};
