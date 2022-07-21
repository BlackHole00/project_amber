#pragma once

#include "../components/components.h"
#include "../../utils/casts.h"

namespace vx {

struct SimpleTransform {
    PositionComponent position;
    RotationComponent rotation;

    VX_COMPONENT_EXPORT(PositionComponent, position);
    VX_COMPONENT_EXPORT(RotationComponent, rotation);

    SimpleTransform(PositionComponent position, RotationComponent rotation) {
        this->position = position;
        this->rotation = rotation;
    }
};

};
