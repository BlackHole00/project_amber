#pragma once

#include "../types.h"

#define VX_CREATE_DEFAULT(_TYPE, ...)               \
template <>                                         \
inline _TYPE vx::default_value<_TYPE>() {           \
    return { __VA_ARGS__ };                         \
}

namespace vx {

template <typename T>
T default_value() {
    return T {};
}

};

VX_CREATE_DEFAULT(u8,  0)
VX_CREATE_DEFAULT(u16, 0)
VX_CREATE_DEFAULT(u32, 0)
VX_CREATE_DEFAULT(u64, 0)
VX_CREATE_DEFAULT(i8,  0)
VX_CREATE_DEFAULT(i16, 0)
VX_CREATE_DEFAULT(i32, 0)
VX_CREATE_DEFAULT(i64, 0)
VX_CREATE_DEFAULT(f32, 0.0f)
VX_CREATE_DEFAULT(f64, 0.0f)

/* EXAMPLE:
*       // You can either set the default values in the struct declaration
*       // or using the VX_CREATE_DEFAULT macro.
*       // When using the macro, the default constructor will not be overwritten.
*
*       struct Foo {
*           int a = 100;
*           int b = 20;
*       }
*
*       struct Bar {
*           int a;
*           int b;
*       }
*       VX_CREATE_DEFAULT(Bar,
*           10, 50
*       )
*
*       int main() {
*           Foo foo;                            // { a = 100, b = 20 }
*           foo.a = 75;                         // { a = 75,  b = 20 }
*           foo = vx::default_value<Foo>();     // { a = 100, b = 20 }
*
*           Bar bar;                            // { a = 0,   b = 0  }
*           bar.a = 20;                         // { a = 20,  b = 0  }
*           bar = vx::default_value<Bar>();     // { a = 10,  b = 50 }
*      }
*/
