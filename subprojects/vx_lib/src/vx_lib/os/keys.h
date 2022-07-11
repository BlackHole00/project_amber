#pragma once

#define GLFW_INCLUDE_NONE
#include <glfw/glfw3.h>
#include <vx_utils/traits/compare.h>
#include <vx_utils/traits/hash.h>
#include <vx_utils/types.h>
#include <vx_utils/mem.h>

namespace vx {

/**
 * @brief A struct that holds the state of a key or a button.
 * @note VX_DEFAULT available.
 */
struct KeyState {
    bool pressed: 1;
    bool just_pressed: 1;
    bool just_released: 6;
};

enum class KeyboardKey: i16 {   // copied from glfw3.h
    Unknown         = -1,

    Space           = 32,
    Apostrophe      = 39,

    Comma           = 44,
    Minus           = 45,
    Period          = 46,
    Slash           = 47,
    Zero            = 48,
    One             = 49,
    Two             = 50,
    Three           = 51,
    Four            = 52,
    Five            = 53,
    Six             = 54,
    Seven           = 55,
    Eight           = 56,
    Nine            = 57,
    Semicolon       = 59,

    Equal           = 61,

    A               = 65,
    B               = 66,
    C               = 67,
    D               = 68,
    E               = 69,
    F               = 70,
    G               = 71,
    H               = 72,
    I               = 73,
    J               = 74,
    K               = 75,
    L               = 76,
    M               = 77,
    N               = 78,
    O               = 79,
    P               = 80,
    Q               = 81,
    R               = 82,
    S               = 83,
    T               = 84,
    U               = 85,
    V               = 86,
    W               = 87,
    X               = 88,
    Y               = 89,
    Z               = 90,
    LeftBracket     = 91,
    BackSlash       = 92,
    RightBracket    = 93,

    GraveAccent     = 96,
    KeyWorld1       = 161,
    KeyWorld2       = 162,

    Escape          = 256,
    Enter           = 257,
    Tab             = 258,
    BackSpace       = 259,
    Insert          = 260,
    Delete          = 261,
    Right           = 262,
    Left            = 263,
    Down            = 264,
    Up              = 265,
    PageUp          = 266,
    PageDown        = 267,
    Home            = 268,
    End             = 269,

    CapsLock        = 280,
    ScrollLock      = 281,
    NumLock         = 282,
    PrintScreen     = 283,
    Pause           = 284,

    F1              = 290,
    F2              = 291,
    F3              = 292,
    F4              = 293,
    F5              = 294,
    F6              = 295,
    F7              = 296,
    F8              = 297,
    F9              = 298,
    F10             = 299,
    F11             = 300,
    F12             = 301,
    F13             = 302,
    F14             = 303,
    F15             = 304,
    F16             = 305,
    F17             = 306,
    F18             = 307,
    F19             = 308,
    F20             = 309,
    F21             = 310,
    F22             = 311,
    F23             = 312,
    F24             = 313,
    F25             = 314,

    KP0             = 320,
    KP1             = 321,
    KP2             = 322,
    KP3             = 323,
    KP4             = 324,
    KP5             = 325,
    KP6             = 326,
    KP7             = 327,
    KP8             = 328,
    KP9             = 329,
    KpDecimal       = 330,
    KpDivide        = 331,
    KpMultiply      = 332,
    KpSubtract      = 333,
    KpAdd           = 334,
    KpEnter         = 335,
    KpEqual         = 336,

    LeftShift       = 340,
    LeftControl     = 341,
    LeftAlt         = 342,
    LeftSuper       = 343,
    RightShift      = 344,
    RightControl    = 345,
    RightAlt        = 346,
    RightSuper      = 347,
    Menu            = 348,

    Last            = (u16)(KeyboardKey::Menu),
    Count           = 119,
};

};

VX_CREATE_COMPARE(KeyboardKey,
    return (V1 == V2) ? ComparationResult::Equal : ComparationResult::Lesser;
);
VX_CREATE_HASH(KeyboardKey,
    return (u64)(VALUE) * (u64)(158) % (u64)(255);
);
