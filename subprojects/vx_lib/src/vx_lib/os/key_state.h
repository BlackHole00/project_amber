#pragma once

namespace vx {

struct KeyState {
    bool pressed: 1;
    bool just_pressed: 1;
    bool just_released: 1;
};

};
