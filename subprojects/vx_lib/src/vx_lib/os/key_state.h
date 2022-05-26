#pragma once

#include <vx_utils/default.h>

typedef struct {
    bool pressed: 1;
    bool just_pressed: 1;
    bool just_released: 1;
} vx_KeyState;
VX_CREATE_DEFAULT(vx_KeyState,
    .pressed = false,
    .just_pressed = false,
    .just_released = false,
)