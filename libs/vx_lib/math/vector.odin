package vx_lib_math

import "core:math"
import "core:math/linalg/glsl"

vec3_direction :: proc(vec: glsl.vec3) -> glsl.vec3 {
    direction := glsl.vec3 { 0.0, 0.0, 0.0 }

    yaw := vec.x
    pitch := vec.y

    direction.z = math.cos(yaw) * math.cos(pitch)
    direction.y = math.sin(pitch)
    direction.x = math.sin(yaw) * math.cos(pitch)

    direction = glsl.normalize(direction)

    return direction
}