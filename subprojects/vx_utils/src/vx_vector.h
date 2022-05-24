#pragma once
#include <malloc.h>
#include <stdio.h>
#include "vx_types.h"
#include "vx_template.h"
#include "vx_option.h"
#include "vx_mem.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
#define VX_VECTOR_DATA(_VEC) ((_VEC)->data)
#define VX_VD(_VEC) VX_VECTOR_DATA(_VEC)

///////////////////////////////////////////////////////////////////////////////////////////////////
#define _VX_VECTOR_ELEM(T) typedef struct {                                                         \
    T* data;                                                                                        \
    usize length;                                                                                   \
    usize _mem_length;                                                                              \
} VX_TEMPLATE_NAME(T, vx_Vector);
#define _VX_VECTOR_NEW_INL(T) static inline VX_TEMPLATE_NAME(T, vx_Vector) VX_TEMPLATE_NAME(T, vx_vector_new)() {\
    VX_TEMPLATE_NAME(T, vx_Vector) vec;                                                             \
    vec.data = vx_smalloc(0);                                                                       \
    vec.length = 0;                                                                                 \
    vec._mem_length = 0;                                                                            \
    return vec;                                                                                     \
}
#define _VX_VECTOR_FREE_INL(T) static inline void VX_TEMPLATE_NAME(T, vx_vector_free)(VX_TEMPLATE_NAME(T, vx_Vector)* vec) {\
    VX_NULL_ASSERT(vec);                                                                            \
    vx_free(vec->data);                                                                             \
    vec->length = 0;                                                                                \
    vec->_mem_length = 0;                                                                           \
}
#define _VX_VECTOR_CLEAR_INL(T) static inline void VX_TEMPLATE_NAME(T, vx_vector_clear)(VX_TEMPLATE_NAME(T, vx_Vector)* vec) {\
    VX_NULL_ASSERT(vec);                                                                            \
    vec->data = vx_srealloc(vec->data, 0);                                                          \
    vec->length = 0;                                                                                \
    vec->_mem_length = 0;                                                                           \
}
#define _VX_VECTOR_PUSH_INL(T) static inline void VX_TEMPLATE_NAME(T, vx_vector_push)(VX_TEMPLATE_NAME(T, vx_Vector)* vec, T value) {\
    VX_NULL_ASSERT(vec);                                                                            \
    /* If the vector is full, then enlarge it.*/                                                    \
    if (vec->length >= vec->_mem_length) {                                                          \
        vec->_mem_length = (vec->_mem_length == 0) ? 1 : vec->_mem_length * 2;                      \
        vec->data = vx_srealloc(vec->data, vec->_mem_length * sizeof(T));                           \
    }                                                                                               \
    /* Push the new value*/                                                                         \
    VX_VECTOR_DATA(vec)[vec->length] = value;                                                       \
    vec->length++;                                                                                  \
}
#define _VX_VECTOR_POP_INL(T) static inline VX_TEMPLATE_NAME(T, vx_Option) VX_TEMPLATE_NAME(T, vx_vector_pop)(VX_TEMPLATE_NAME(T, vx_Vector)* vec) {\
    VX_NULL_ASSERT(vec);                                                                            \
    if (vec->length > 0) {                                                                          \
        T top = VX_VECTOR_DATA(vec)[vec->length - 1];                                               \
        vec->length--;                                                                              \
        if (vec->length <= (vec->_mem_length / 2)) {                                                \
            vec->_mem_length = vec->_mem_length / 2;                                                \
            vec->data = vx_srealloc(vec->data, vec->_mem_length * sizeof(T));                       \
        }                                                                                           \
        return VX_TEMPLATE_CALL(T, vx_option_some)(top);                                            \
    }                                                                                               \
    return VX_TEMPLATE_CALL(T, vx_option_none)();                                                   \
}
#define _VX_VECTOR_TOP_INL(T) static inline T* VX_TEMPLATE_NAME(T, vx_vector_top)(VX_TEMPLATE_NAME(T, vx_Vector)* vec) {\
    VX_NULL_CHECK(vec, NULL);                                                                       \
    if (vec->length > 0) {                                                                          \
        return &(VX_VECTOR_DATA(vec)[vec->length - 1]);                                             \
    }                                                                                               \
    return NULL;                                                                                    \
}
#define _VX_VECTOR_GET_INL(T) static inline T* VX_TEMPLATE_NAME(T, vx_vector_get)(VX_TEMPLATE_NAME(T, vx_Vector)* vec, u32 index) {\
    VX_NULL_CHECK(vec, NULL);                                                                       \
    if (index < vec->length) {                                                                      \
        return &(VX_VECTOR_DATA(vec)[index]);                                                       \
    }                                                                                               \
    return NULL;                                                                                    \
}
#define _VX_VECTOR_INSERT_INL(T) static inline void VX_TEMPLATE_NAME(T, vx_vector_insert)(VX_TEMPLATE_NAME(T, vx_Vector)* vec, T value, u32 index) {\
    VX_TEMPLATE_CALL(T, vx_vector_push)(vec, value);                                                \
    for (u32 i = (vec->length - 1); i > index; i--) {                                               \
        VX_VECTOR_DATA(vec)[i] = VX_VECTOR_DATA(vec)[i - 1];                                        \
    }                                                                                               \
    VX_VECTOR_DATA(vec)[index] = value;                                                             \
}
#define _VX_VECTOR_REMOVE_INL(T) static inline VX_TEMPLATE_NAME(T, vx_Option) VX_TEMPLATE_NAME(T, vx_vector_remove)(VX_TEMPLATE_NAME(T, vx_Vector)* vec, u32 index) {\
    if (index >= vec->length || index < 0) {                                                        \
        return VX_TEMPLATE_CALL(T, vx_option_none)();                                               \
    }                                                                                               \
    T value = VX_VECTOR_DATA(vec)[index];                                                           \
    for (u32 i = index; i < vec->length - 1; i++) {                                                 \
        VX_VECTOR_DATA(vec)[i] = VX_VECTOR_DATA(vec)[i + 1];                                        \
    }                                                                                               \
    VX_TEMPLATE_CALL(T, vx_vector_pop)(vec);                                                        \
    return VX_TEMPLATE_CALL(T, vx_option_some)(value);                                              \
}
#define _VX_VECTOR_CLONE_INL(T) static inline void VX_TEMPLATE_NAME(T, vx_vector_clone)(VX_TEMPLATE_NAME(T, vx_Vector)* vec, VX_TEMPLATE_NAME(T, vx_Vector)* dest) {\
    VX_NULL_ASSERT(vec);                                                                            \
    VX_NULL_ASSERT(dest);                                                                           \
    VX_TEMPLATE_CALL(T, vx_vector_clear)(dest);                                                     \
    for (int i = 0; i < vec->length; i++) {                                                         \
        VX_TEMPLATE_CALL(T, vx_vector_push)(dest, VX_VECTOR_DATA(vec)[i]);                          \
    }                                                                                               \
}
#define _VX_VECTOR_COPY_TO_BUFFER_INL(T) static inline void VX_TEMPLATE_NAME(T, vx_vector_copy_to_buffer)(VX_TEMPLATE_NAME(T, vx_Vector)* vec, T* buffer, u32 size) {\
    VX_NULL_ASSERT(buffer);                                                                         \
    for (int i = 0; i < vec->length && i < size; i++) {                                             \
        buffer[i] = VX_VECTOR_DATA(vec)[i];                                                         \
    }                                                                                               \
}
#define VX_VECTOR_FOREACH(_T, _ELEM_NAME, _VEC, ...) for(u32 I = 0; I < (_VEC)->length; I++) {      \
    _T _ELEM_NAME = VX_VECTOR_DATA(_VEC)[I]; __VA_ARGS__                                            \
}
#define VX_VECTOR_FOREACHMUT(_T, _ELEM_NAME, _VEC, ...) for(u32 I = 0; I < (_VEC)->length; I++) {      \
    _T* _ELEM_NAME = &VX_VECTOR_DATA(_VEC)[I]; __VA_ARGS__                                            \
}

#define _VX_VECTOR_CREATE_FOR_TYPE(_T) VX_TEMPLATE_ELEM(_T, _VX_VECTOR_ELEM)                        \
VX_TEMPLATE_INL(_T, _VX_VECTOR_NEW_INL)                                                             \
VX_TEMPLATE_INL(_T, _VX_VECTOR_FREE_INL)                                                            \
VX_TEMPLATE_INL(_T, _VX_VECTOR_CLEAR_INL)                                                           \
VX_TEMPLATE_INL(_T, _VX_VECTOR_PUSH_INL)                                                            \
VX_TEMPLATE_INL(_T, _VX_VECTOR_POP_INL)                                                             \
VX_TEMPLATE_INL(_T, _VX_VECTOR_TOP_INL)                                                             \
VX_TEMPLATE_INL(_T, _VX_VECTOR_GET_INL)                                                             \
VX_TEMPLATE_INL(_T, _VX_VECTOR_INSERT_INL)                                                          \
VX_TEMPLATE_INL(_T, _VX_VECTOR_REMOVE_INL)                                                          \
VX_TEMPLATE_INL(_T, _VX_VECTOR_CLONE_INL)                                                           \
VX_TEMPLATE_INL(_T, _VX_VECTOR_COPY_TO_BUFFER_INL)                                                  \

///////////////////////////////////////////////////////////////////////////////////////////////////

_VX_VECTOR_CREATE_FOR_TYPE(u8)
_VX_VECTOR_CREATE_FOR_TYPE(u16)
_VX_VECTOR_CREATE_FOR_TYPE(u32)
_VX_VECTOR_CREATE_FOR_TYPE(u64)
_VX_VECTOR_CREATE_FOR_TYPE(i8)
_VX_VECTOR_CREATE_FOR_TYPE(i16)
_VX_VECTOR_CREATE_FOR_TYPE(i32)
_VX_VECTOR_CREATE_FOR_TYPE(i64)
_VX_VECTOR_CREATE_FOR_TYPE(f32)
_VX_VECTOR_CREATE_FOR_TYPE(f64)

/*  EXAMPLE:
*       int main() {
*           VX_T(i32, vx_Vector) vec = vx_vector_new();
*           VX_T(i32, vx_vector_push)(&vec, 1);
*           VX_T(i32, vx_vector_push)(&vec, 2);
*           VX_T(i32, vx_vector_push)(&vec, 3);
*           VX_T(i32, vx_vector_push)(&vec, 4);
*           VX_T(i32, vx_vector_push)(&vec, 5);
*
*           printf("The second element in the vector is %d.\n", VX_VD(&vec)[1]);
*           printf("The number elements in the vector is %d. The size in memory of the vector is %d\n", vec.length, vec.mem_length);
*           printf("The top element is %d\n", *VX_T(i32, vx_vector_top)(&vec));
*
*           VX_T(i32, vx_Option) i;
*           while(i = VX_T(i32, vx_vector_pop)(&vec), i.is_some) {
*               printf("Popped %d\n", i.data);
*           }
*
*           vx_vector_clear(&vec);
*      }
*/
