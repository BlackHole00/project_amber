/**
 * @file vx_lib/logic/components/helpers/vector_builder.h
 * @brief Implemented because cpp does not have hard aliases/typedefs.
 */

#include <vx_utils/types.h>
#include <vx_utils/mem.h>

#if defined(VX_BUILD_VEC2) || defined(VX_BUILD_VEC3) || defined(VX_BUILD_VEC4)
    #error "Remember to include vector_builder_undef.h when you finish to use vector_builder.h"
#endif


#define VX_BUILD_VEC2(_T, _NAME)                                                \
struct _NAME {                                                                  \
    union {                                                                     \
        _T x;                                                                   \
        _T width;                                                               \
    };                                                                          \
    union {                                                                     \
        _T y;                                                                   \
        _T height;                                                              \
    };                                                                          \
    _NAME() {}                                                                  \
    _NAME(_T x, _T y) { this->x = x; this->y = y; }                             \
    _NAME(const ::vx::Vec3<_T>& other) { x = other.x; y = other.y; }            \
    operator ::vx::Vec2<_T>() { return VX_TRANSMUTE(::vx::Vec2<_T>, *this); }   \
    _NAME& operator=(const ::vx::Vec2<_T>& other) { x = other.x; y = other.y; return *this; }\
};

#define VX_BUILD_VEC3(_T, _NAME)                                                \
struct _NAME {                                                                  \
    union {                                                                     \
        _T x;                                                                   \
        _T width;                                                               \
        _T r;                                                                   \
    };                                                                          \
    union {                                                                     \
        _T y;                                                                   \
        _T height;                                                              \
        _T g;                                                                   \
    };                                                                          \
    union {                                                                     \
        _T z;                                                                   \
        _T b;                                                                   \
    };                                                                          \
    _NAME() {}                                                                  \
    _NAME(_T x, _T y, _T z) { this->x = x; this->y = y; this->z = z; }          \
    _NAME(const ::vx::Vec3<_T>& other) { x = other.x; y = other.y; z = other.z; }\
    operator ::vx::Vec3<_T>() { return VX_TRANSMUTE(::vx::Vec3<_T>, *this); }   \
    _NAME& operator=(const ::vx::Vec3<_T>& other) { x = other.x; y = other.y; z = other.z; return *this; }\
};

#define VX_BUILD_VEC4(_T, _NAME)                                                \
struct _NAME {                                                                  \
    union {                                                                     \
        _T x;                                                                   \
        _T width;                                                               \
        _T r;                                                                   \
    };                                                                          \
    union {                                                                     \
        _T y;                                                                   \
        _T height;                                                              \
        _T g;                                                                   \
    };                                                                          \
    union {                                                                     \
        _T z;                                                                   \
        _T b;                                                                   \
    };                                                                          \
    union {                                                                     \
        T w;                                                                    \
        T a;                                                                    \
    };                                                                          \
    _NAME() {}                                                                  \
    _NAME(_T x, _T y, _T z, _T w) { this->x = x; this->y = y; this->z = z; this->w = w; }\
    _NAME(const ::vx::Vec4<_T>& other) { x = other.x; y = other.y; z = other.z; w = other.y; }\
    operator ::vx::Vec4<_T>() { return VX_TRANSMUTE(::vx::Vec3<_T>, *this); }   \
    _NAME& operator=(const ::vx::Vec4<_T>& other) { x = other.x; y = other.y; z = other.z; w = other.y; return *this; }\
};
