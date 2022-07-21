#pragma once

#include "../components/components.h"
#include "../../utils/casts.h"

namespace vx {

struct FullTransform {
    PositionComponent position;
    RotationComponent rotation;
    ScaleComponent scale;

    VX_COMPONENT_EXPORT(PositionComponent, position);
    VX_COMPONENT_EXPORT(RotationComponent, rotation);
    VX_COMPONENT_EXPORT(ScaleComponent, scale);

    FullTransform() {}
    FullTransform(PositionComponent position, RotationComponent rotation, ScaleComponent scale) {
        this->position = position;
        this->rotation = rotation;
        this->scale = scale;
    }
};

};