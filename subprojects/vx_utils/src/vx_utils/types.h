#pragma once
#include <cstdint>

#define var auto

typedef std::uint8_t byte;
typedef std::uint8_t u8;
typedef std::uint16_t u16;
typedef std::uint32_t u32;
typedef std::uint64_t u64;

typedef std::int8_t i8;
typedef std::int16_t i16;
typedef std::int32_t i32;
typedef std::int64_t i64;

typedef float f32;
typedef double f64;

typedef std::size_t usize;

#ifdef __ssize_t_defined
typedef ssize_t isize;
#endif

typedef char* rawstr;

namespace vx {

template <class T>
struct Vec2 {
    union {
        T x;
        T width;
    };
    union {
        T y;
        T height;
    };

    Vec2() {}
    Vec2(T x, T y) {
        this->x = x;
        this->y = y;
    }
};

template <class T>
inline constexpr Vec2<T> vec2_new(T v1, T v2) {
    return Vec2<T> { v1, v2 };
}

template <class T>
struct Vec3 {
    union {
        T x;
        T width;
        T r;
    };
    union {
        T y;
        T height;
        T g;
    };
    union {
        T z;
        T b;
    };

    Vec3() {}
    Vec3(T x, T y, T z) {
        this->x = x;
        this->y = y;
        this->z = z;
    }
};

template <class T>
inline constexpr Vec3<T> vec3_new(T v1, T v2, T v3) {
    return Vec3<T> { v1, v2, v3 };
}

template <class T>
struct Vec4 {
    union {
        T x;
        T width;
        T r;
    };
    union {
        T y;
        T height;
        T g;
    };
    union {
        T z;
        T b;
    };
    union {
        T w;
        T a;
    };

    Vec4() {}
    Vec4(T x, T y, T z, T w) {
        this->x = x;
        this->y = y;
        this->z = z;
        this->w = w;
    }
};

template <class T>
inline constexpr Vec4<T> vec4_new(T v1, T v2, T v3, T v4) {
    return Vec4<T> { v1, v2, v3, v4 };
}

};
