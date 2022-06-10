#pragma once

#include "macro.h"
#include "mem.h"
#include "option.h"
#include "vector.h"
#include "defer.h"
#include "traits/compare.h"
#include "traits/hash.h"

namespace vx {

#define _VX_HASHTABLE_MEM_LENGTH(HT) (HT)->elements.length

// T must implement vx::hash
// K must implement vx::compare
template <class T, class K>
struct HashTableBucket {
    T value;
    K key;
};

// K must implement vx::hash and vx::compare
template <class T, class K>
struct HashTable {
    vx::Vector<vx::Option<HashTableBucket<T, K>>> elements;
    u32 num_elems;
};

template <class T, class K>
HashTable<T, K> hash_table_new(Allocator* allocator = nullptr) {
    HashTable<T, K> ht;

    ht.elements = vector_new<vx::Option<HashTableBucket<T, K>>>(1, allocator);
    ht.num_elems = 0;

    ht.elements[0] = vx::option_none<HashTableBucket<T, K>>();

    return ht;
}

template <class T, class K>
void hash_table_free(HashTable<T, K>* hash_table) {
    vector_free(&hash_table->elements);
}

template <class T, class K>
void _raw_hash_table_set(HashTable<T, K>* hash_table, K key, T value) {
    bool new_entry = true;
    u64 hash = vx::hash(key) % _VX_HASHTABLE_MEM_LENGTH(hash_table);
    while (hash_table->elements[hash].is_some) {
        if (compare(option_unwrap(hash_table->elements[hash]).key, key) == ComparationResult::Equal) {
            new_entry = false;
            break;
        }

        hash += 1;
        hash %= _VX_HASHTABLE_MEM_LENGTH(hash_table);
    }

    hash_table->elements[hash] = option_some(HashTableBucket<T, K> { value, key });

    if (new_entry) {
        hash_table->num_elems++;
    }
}

template <class T, class K>
void hash_table_set(HashTable<T, K>* hash_table, K key, T value) {
    _hash_table_resize(hash_table);
    _raw_hash_table_set(hash_table, key, value);

}

template <class T, class K>
T* hash_table_get(HashTable<T, K>* hash_table, K key) {
    u64 hash = vx::hash(key) % _VX_HASHTABLE_MEM_LENGTH(hash_table);

    if (!hash_table->elements[hash].is_some) {
        return nullptr;
    }

    while (compare(option_unwrap(hash_table->elements[hash]).key, key) != ComparationResult::Equal) {
        hash += 1;
        hash %= _VX_HASHTABLE_MEM_LENGTH(hash_table);
    }

    return &option_unwrap(&hash_table->elements[hash])->value;
}

template <class T, class K>
Option<T> hash_table_remove(HashTable<T, K>* hash_table, K key) {
    u64 hash = vx::hash(key) % _VX_HASHTABLE_MEM_LENGTH(hash_table);

    if (!hash_table->elements[hash].is_some) {
        return option_none<T>();
    }

    while (compare(option_unwrap(hash_table->elements[hash]).key, key) != ComparationResult::Equal) {
        hash += 1;
        hash %= _VX_HASHTABLE_MEM_LENGTH(hash_table);
    }

    Option<T> return_value = option_some<T>(option_unwrap(hash_table->elements[hash]).value);

    hash_table->elements[hash] = option_none<HashTableBucket<T, K>>();

    return return_value;
}

template <class T, class K>
void _hash_table_resize(HashTable<T, K>* hash_table) {
    if (hash_table->num_elems < hash_table->elements.length) {
        return;
    }

    vector_resize(&hash_table->elements, _VX_HASHTABLE_MEM_LENGTH(hash_table) * 2);

    vx::Vector<HashTableBucket<T, K>> buckets = vector_new<HashTableBucket<T, K>>(0, hash_table->elements._allocator);
    VX_DEFER(vector_free(&buckets));

    for (usize i = 0; i < hash_table->num_elems; i++) {
        if (hash_table->elements[i].is_some) {
            vector_push(&buckets, option_unwrap(hash_table->elements[i]));
        }
    }

    for (usize i = 0; i < _VX_HASHTABLE_MEM_LENGTH(hash_table); i++) {
        hash_table->elements[i] = option_none<HashTableBucket<T, K>>();
    }

    hash_table->num_elems = 0;
    for (usize i = 0; i < buckets.length; i++) {
        _raw_hash_table_set(hash_table, buckets[i].key, buckets[i].value);
    }
}

template <class T, class K>
void _hash_table_dbg(HashTable<T, K>* hash_table) {
    printf("\n");
    for(usize i = 0; i < _VX_HASHTABLE_MEM_LENGTH(hash_table); i++) {
        if (hash_table->elements[i].is_some) {
            printf("%lld: SOME(%s: %i)\n", i, option_unwrap(hash_table->elements[i]).key, option_unwrap(hash_table->elements[i]).value);
        } else {
            printf("%lld: NONE\n", i);
        }
    }
}

};

VX_CREATE_CLONE_T(VX_MACRO_ARG(template <class T, class K>), VX_MACRO_ARG(HashTable<T, K>),
    VX_NULL_ASSERT(SOURCE);
    VX_NULL_ASSERT(DEST);

    DEST->num_elems = SOURCE->num_elems;
    clone(&SOURCE->elements, &DEST->elements);
)

VX_CREATE_LEN_T(VX_MACRO_ARG(template <class T, class K>), VX_MACRO_ARG(HashTable<T, K>*),
    VX_NULL_ASSERT(VALUE);

    return VALUE->num_elems;
)

#undef _VX_HASHTABLE_MEM_LENGTH
