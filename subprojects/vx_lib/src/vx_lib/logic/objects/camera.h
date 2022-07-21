#pragma once

#include "../components/components.h"
#include "../../utils/casts.h"

namespace vx {

struct BasicCamera {
    PositionComponent position;
    RotationComponent rotation;
    CameraComponent camera;

    VX_COMPONENT_EXPORT(PositionComponent, position);
    VX_COMPONENT_EXPORT(RotationComponent, rotation);
    VX_COMPONENT_EXPORT(CameraComponent,   camera);

    BasicCamera() {}
    BasicCamera(CameraComponent camera, PositionComponent position, RotationComponent rotation) {
        this->position = position;
        this->rotation = rotation;
        this->camera = camera;
    }
};

};
