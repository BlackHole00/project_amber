/**
 * @file vx_lib/logic/components/helpers/vector_builder.h
 * @brief Implemented because cpp does not have hard aliases/typedefs.
 */

#include <vx_utils/types.h>
#include <vx_utils/mem.h>
#include <bx/math.h>

#if defined(VX_BUILD_VEC2) || defined(VX_BUILD_VEC3) || defined(VX_BUILD_VEC4)
    #error "Remember to include vector_builder_undef.h when you finish to use vector_builder.h"
#endif


#define VX_BUILD_VEC2(_NAME)                                                    \
struct _NAME {                                                                  \
    union {                                                                     \
        f32 x;                                                                  \
        f32 width;                                                              \
        f32 yaw;                                                                \
    };                                                                          \
    union {                                                                     \
        f32 y;                                                                  \
        f32 height;                                                             \
        f32 pitch;                                                              \
    };                                                                          \
    _NAME() {}                                                                  \
    _NAME(f32 x, f32 y) { this->x = x; this->y = y; }                           \
    _NAME(const ::vx::Vec2<f32>& other) const { x = other.x; y = other.y; }           \
    operator ::vx::Vec2<f32>() { return VX_TRANSMUTE(::vx::Vec2<f32>, *this); }\
    _NAME& operator=(const ::vx::Vec2<f32>& other) { x = other.x; y = other.y; return *this; }\
};

#define VX_BUILD_VEC3(_NAME)                                                    \
struct _NAME {                                                                  \
    union {                                                                     \
        f32 x;                                                                  \
        f32 width;                                                              \
        f32 r;                                                                  \
        f32 yaw;                                                                \
    };                                                                          \
    union {                                                                     \
        f32 y;                                                                  \
        f32 height;                                                             \
        f32 g;                                                                  \
        f32 pitch;                                                              \
    };                                                                          \
    union {                                                                     \
        f32 z;                                                                  \
        f32 b;                                                                  \
    };                                                                          \
    _NAME() {}                                                                  \
    _NAME(f32 x, f32 y, f32 z) { this->x = x; this->y = y; this->z = z; }       \
    _NAME(const ::vx::Vec3<f32>& other) { x = other.x; y = other.y; z = other.z; }\
    _NAME(const bx::Vec3& other) { x = other.x; y = other.y; z = other.z; }     \
    operator ::vx::Vec3<f32>() const { return VX_TRANSMUTE(::vx::Vec3<f32>, *this); }\
    operator bx::Vec3() const { return bx::Vec3 { x, y, z}; }                         \
    _NAME& operator=(const ::vx::Vec3<f32>& other) { x = other.x; y = other.y; z = other.z; return *this; }\
};

#define VX_BUILD_VEC4(_NAME)                                                    \
struct _NAME {                                                                  \
    union {                                                                     \
        f32 x;                                                                  \
        f32 width;                                                              \
        f32 r;                                                                  \
        f32 yaw;                                                                \
    };                                                                          \
    union {                                                                     \
        f32 y;                                                                  \
        f32 height;                                                             \
        f32 g;                                                                  \
        f32 pitch;                                                              \
    };                                                                          \
    union {                                                                     \
        f32 z;                                                                  \
        f32 b;                                                                  \
    };                                                                          \
    union {                                                                     \
        T w;                                                                    \
        T a;                                                                    \
    };                                                                          \
    _NAME() {}                                                                  \
    _NAME(f32 x, f32 y, f32 z, f32 w) { this->x = x; this->y = y; this->z = z; this->w = w; }\
    _NAME(const ::vx::Vec4<f32>& other) const { x = other.x; y = other.y; z = other.z; w = other.y; }\
    operator ::vx::Vec4<f32>() { return VX_TRANSMUTE(::vx::Vec3<f32>, *this); }   \
    _NAME& operator=(const ::vx::Vec4<f32>& other) { x = other.x; y = other.y; z = other.z; w = other.y; return *this; }\
};
