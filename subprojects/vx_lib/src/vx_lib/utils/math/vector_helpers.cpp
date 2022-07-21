#include "vector_helpers.h"

#include <cmath>
#include <vx_utils/math.h>

namespace vx {
    bx::Vec3 direction(bx::Vec3 vec) {
        bx::Vec3 direction = bx::Vec3 { 0.0f, 0.0f, 0.0f };

        float yaw = vec.x;
        float pitch = vec.y;

        direction.x = std::cos(vx::deg_to_rad(yaw)) * cos(vx::deg_to_rad(pitch));
        direction.y = std::sin(vx::deg_to_rad(pitch));
        direction.z = std::sin(vx::deg_to_rad(yaw)) * cos(vx::deg_to_rad(pitch));

        direction = bx::normalize(direction);

        return direction;
    }
};
