#pragma once
#include "vx_types.h"
#include "vx_vector.h"

typedef u64 vx_HashMap_Hash;

static inline u32 _vx_hashmap_find_optimal_pos(VX_T(u64, vx_Vector)* hashes, u64 hash) {
    u32 i = 0;
    while(VX_VD(hashes)[i] < hash) {
        i++;
    }

    return i;
}

static inline VX_T(u32, vx_Option) _vx_hashmap_find_hash_index(VX_T(u64, vx_Vector)* hashes, u64 hash) {
    u32 top = (u32)hashes->length;
    u32 bottom = 0;
    u32 center;

    do {
        center = (top + bottom) / 2;

        if (VX_VD(hashes)[center] == hash) {
            return VX_T(u32, vx_option_some)(center);
        }
        if (VX_VD(hashes)[center] > hash) {
            top = center - 1;
        } else if (VX_VD(hashes)[center] < hash) {
            bottom = center + 1;
        }
    } while (bottom <= top);

    return VX_T(u32, vx_option_none)();
}

#define _VX_HASHMAP_ELEM(T) typedef struct {                                                        \
    VX_TEMPLATE_NAME(T, vx_Vector) values;                                                          \
    VX_TEMPLATE_NAME(u64, vx_Vector) hashes;                                                        \
    u32 length;                                                                                     \
} VX_TEMPLATE_NAME(T, vx_HashMap);
#define _VX_HASHMAP_NEW_INL(T) static inline VX_TEMPLATE_NAME(T, vx_HashMap) VX_TEMPLATE_NAME(T, vx_hashmap_new)() {\
    VX_TEMPLATE_NAME(T, vx_HashMap) map;                                                            \
    map.values = VX_T(T, vx_vector_new)();                                                          \
    map.hashes = VX_T(u64, vx_vector_new)();                                                        \
    map.length = 0;                                                                                 \
    return map;                                                                                     \
}
#define _VX_HASHMAP_FREE_INL(T) static inline void VX_TEMPLATE_NAME(T, vx_hashmap_free)(VX_TEMPLATE_NAME(T, vx_HashMap)* map) {\
    VX_T(T, vx_vector_free)(&map->values);                                                          \
    VX_T(u64, vx_vector_free)(&map->hashes);                                                        \
    map->length = 0;                                                                                \
}
#define _VX_HASHMAP_GET_INL(T) static inline T* VX_TEMPLATE_NAME(T, vx_hashmap_get)(VX_TEMPLATE_NAME(T, vx_HashMap)* map, vx_HashMap_Hash hash) {\
    VX_TEMPLATE_NAME(u32, vx_Option) index = _vx_hashmap_find_hash_index(&map->hashes, hash);       \
    if (!index.is_some) {                                                                           \
        return NULL;                                                                                \
    }                                                                                               \
    return &VX_VECTOR_DATA(&map->values)[index.data];                                               \
}
#define _VX_HASHMAP_INSERT_INL(T) static inline void VX_TEMPLATE_NAME(T, vx_hashmap_insert)(VX_TEMPLATE_NAME(T, vx_HashMap)* map, T value, vx_HashMap_Hash hash) {\
    if (map->length <= 0) {                                                                         \
        VX_TEMPLATE_CALL(T, vx_vector_push)(&map->values, value);                                   \
        VX_TEMPLATE_CALL(u64, vx_vector_push)(&map->hashes, hash);                                  \
        map->length++;                                                                              \
        return;                                                                                     \
    }                                                                                               \
    u32 optimal_pos = _vx_hashmap_find_optimal_pos(&map->hashes, hash);                             \
    VX_TEMPLATE_CALL(T, vx_vector_insert)(&map->values, value, optimal_pos);                        \
    VX_TEMPLATE_CALL(u64, vx_vector_insert)(&map->hashes, hash, optimal_pos);                       \
    map->length++;                                                                                  \
}
#define _VX_HASHMAP_REMOVE_INL(T) static inline VX_TEMPLATE_NAME(T, vx_Option) VX_TEMPLATE_NAME(T, vx_hashmap_remove)(VX_TEMPLATE_NAME(T, vx_HashMap)* map, vx_HashMap_Hash hash) {\
    if (map->length <= 0) {                                                                         \
        return VX_TEMPLATE_CALL(T, vx_option_none)();                                               \
    }                                                                                               \
    VX_TEMPLATE_NAME(u32, vx_Option) index = _vx_hashmap_find_hash_index(&map->hashes, hash);       \
    if (!index.is_some) {                                                                           \
        return VX_TEMPLATE_CALL(T, vx_option_none)();                                               \
    }                                                                                               \
    VX_TEMPLATE_CALL(u64, vx_vector_remove)(&map->hashes, index.data);                              \
    return VX_TEMPLATE_CALL(T, vx_vector_remove)(&map->values, index.data);                         \
}
#define VX_HASHMAP_FOREACH(_T, _ELEM_NAME, _MAP, ...) for(u32 I = 0; I < (_MAP)->length; I++) {     \
    _T _ELEM_NAME = VX_VECTOR_DATA(&((_MAP)->values))[I]; __VA_ARGS__                               \
}

#define _VX_HASHMAP_CREATE_FOR_TYPE(_T) VX_TEMPLATE_ELEM(_T, _VX_HASHMAP_ELEM)                      \
VX_TEMPLATE_INL(_T, _VX_HASHMAP_NEW_INL)                                                            \
VX_TEMPLATE_INL(_T, _VX_HASHMAP_FREE_INL)                                                           \
VX_TEMPLATE_INL(_T, _VX_HASHMAP_GET_INL)                                                            \
VX_TEMPLATE_INL(_T, _VX_HASHMAP_INSERT_INL)                                                         \
VX_TEMPLATE_INL(_T, _VX_HASHMAP_REMOVE_INL)

_VX_HASHMAP_CREATE_FOR_TYPE(u8)
_VX_HASHMAP_CREATE_FOR_TYPE(u16)
_VX_HASHMAP_CREATE_FOR_TYPE(u32)
_VX_HASHMAP_CREATE_FOR_TYPE(u64)
_VX_HASHMAP_CREATE_FOR_TYPE(i8)
_VX_HASHMAP_CREATE_FOR_TYPE(i16)
_VX_HASHMAP_CREATE_FOR_TYPE(i32)
_VX_HASHMAP_CREATE_FOR_TYPE(i64)
_VX_HASHMAP_CREATE_FOR_TYPE(f32)
_VX_HASHMAP_CREATE_FOR_TYPE(f64)
