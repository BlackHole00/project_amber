#pragma once

#include "macro.h"
#include "mem.h"
#include "option.h"
#include "vector.h"
#include "defer.h"
#include "traits/compare.h"
#include "traits/hash.h"
#include "traits/iterator.h"

namespace vx {

#define _VX_HASHTABLE_MEM_LENGTH(HT) (HT)->elements.length

/**
 * @enum INTERNAL - HashTableBucketState
 * @brief Defines the state of a bucket.
 */
enum class HashTableBucketState: byte {
    Empty,
    Deleted,
    Used
};

/**
 * @class INTERNAL - HashTableBucket
 * @brief An internal class used to store an item and its key.
 * @param T The type of the value.
 * @param K The type of the key. Must implement vx::hash and vx::compare.
 */
template <class T, class K>
struct HashTableBucket {
    HashTableBucketState state = HashTableBucketState::Empty;
    T value;
    K key;
};

/**
 * @class HashTableBucket
 * @brief A simple hash table (not optimal for now).
 * @param T The type of the value.
 * @param K The type of the key. Must implement vx::hash and vx::compare.
 * @implements clone, len
 */
template <class T, class K>
struct HashTable {
    Vector<HashTableBucket<T, K>> elements;
    u32 num_elems;

    Allocator* _allocator;
};

/**
 * @brief Creates a new hash table.
 * @param allocator A pointer to an allocator. If nullptr, the current allocator from the AllocatorStack will be used.
 */
template <class T, class K>
HashTable<T, K> hashtable_new(Allocator* allocator = nullptr) {
    VX_VALIDATE_ALLOCATOR(allocator);

    HashTable<T, K> ht;

    ht._allocator = allocator;

    ht.elements = vector_new<HashTableBucket<T, K>>(1, allocator);
    ht.num_elems = 0;

    ht.elements[0].state = HashTableBucketState::Empty;

    return ht;
}

/**
 * @brief Creates a new hash table with a defined number of empty buckets.
 * @param size The number of empty buckets.
 * @param allocator A pointer to an allocator. If nullptr, the current allocator from the AllocatorStack will be used.
 */
template <class T, class K>
HashTable<T, K> hashtable_new_with_size(usize size, Allocator* allocator = nullptr) {
    VX_VALIDATE_ALLOCATOR(allocator);

    HashTable<T, K> ht = hashtable_new<T, K>(allocator);

    _hashtable_resize(&ht, size);

    return ht;
}

/**
 * @brief Frees an hash table.
 */
template <class T, class K>
void hashtable_free(HashTable<T, K>* hash_table) {
    vector_free(&hash_table->elements);
}

/**
 * @brief INTERNAL - Sets a key on the table without checking for resizing.
 */
template <class T, class K>
void _raw_hashtable_set(HashTable<T, K>* hash_table, K key, T value) {
    bool new_entry = true;
    u64 hash_value = hash(key) % _VX_HASHTABLE_MEM_LENGTH(hash_table);
    while (hash_table->elements[hash_value].state == HashTableBucketState::Used) {
        /* If true, the key hash already been inserted, so we sould override its value. */
        if (compare(hash_table->elements[hash_value].key, key) == ComparationResult::Equal) {
            new_entry = false;
            break;
        }

        /* Otherwise update the hash. */
        hash_value += 1;
        hash_value %= _VX_HASHTABLE_MEM_LENGTH(hash_table);
    }

    hash_table->elements[hash_value] = HashTableBucket<T, K> { HashTableBucketState::Used, value, key };

    if (new_entry) {
        hash_table->num_elems++;
    }
}

/**
 * @brief INTERNAL - Resizes a table (This operation rehashes all the elements).
 */
template <class T, class K>
void _hashtable_resize(HashTable<T, K>* hash_table, usize new_len) {
    vector_resize(&hash_table->elements, new_len);

    Vector<HashTableBucket<T, K>> buckets = vector_new<HashTableBucket<T, K>>(0, hash_table->_allocator);
    VX_DEFER(vector_free(&buckets));

    for (usize i = 0; i < _VX_HASHTABLE_MEM_LENGTH(hash_table); i++) {
        if (hash_table->elements[i].state == HashTableBucketState::Used) {
            vector_push(&buckets, hash_table->elements[i]);
        }
    }

    for (usize i = 0; i < _VX_HASHTABLE_MEM_LENGTH(hash_table); i++) {
        hash_table->elements[i].state = HashTableBucketState::Empty;
    }

    hash_table->num_elems = 0;
    for (usize i = 0; i < buckets.length; i++) {
        _raw_hashtable_set(hash_table, buckets[i].key, buckets[i].value);
    }
}

/**
 * @brief INTERNAL - Resizes a table if more space is needed.
 */
template <class T, class K>
void _hashtable_check_resize(HashTable<T, K>* hash_table) {
    /* There should always be an empty slot in the table. */
    if ((hash_table->num_elems + 1) < hash_table->elements.length) {
        return;
    }

    _hashtable_resize(hash_table, _VX_HASHTABLE_MEM_LENGTH(hash_table) * 2);
}

/**
 * @brief Inserts a pair of key and value in the table.
 */
template <class T, class K>
void hashtable_set(HashTable<T, K>* hash_table, K key, T value) {
    _hashtable_check_resize(hash_table);
    _raw_hashtable_set(hash_table, key, value);

}

/**
 * @brief Returns a pointer to the value associated with a key.
 * @return Returns nullptr if the key was not found.
 */
template <class T, class K>
T* hashtable_get(HashTable<T, K>* hash_table, K key) {
    u64 hash_value = hash(key) % _VX_HASHTABLE_MEM_LENGTH(hash_table);

    /* If the bucket at the hash position is empty, then the key does not exists. */
    if (hash_table->elements[hash_value].state != HashTableBucketState::Used) {
        return nullptr;
    }

    bool ok = false;
    do {
        /* If the key is found we exit from the cycle. */
        if (compare(hash_table->elements[hash_value].key, key) == ComparationResult::Equal) {
            ok = true;
            break;
        }

        hash_value += 1;
        hash_value %= _VX_HASHTABLE_MEM_LENGTH(hash_table);
    } while (hash_table->elements[hash_value].state != HashTableBucketState::Empty);   /* Repeat until we found an empty bucket. */

    if (ok) {
        return &hash_table->elements[hash_value].value;
    } else {
        return nullptr;
    }
}

template <class T, class K>
T* hashtable_get_or_insert(HashTable<T, K>* hash_table, K key) {
    T* value = hashtable_get(hash_table, key);
    if (value != nullptr) {
        return value;
    }

    hashtable_set(hash_table, key, T { });

    return hashtable_get(hash_table, key);
} 

/**
 * @brief Removes a key and its associated value form the table.
 * @return Returns OptionNone if the key was not found. Returns OptionSome with the remove value otherwise.
 */
template <class T, class K>
Option<T> hashtable_remove(HashTable<T, K>* hash_table, K key) {
    u64 hash_value = hash(key) % _VX_HASHTABLE_MEM_LENGTH(hash_table);

    if (hash_table->elements[hash_value].state != HashTableBucketState::Used) {
        return option_none<T>();
    }

    bool ok = false;
    do {
        /* If the key is found we exit from the cycle. */
        if (compare(hash_table->elements[hash_value].key, key) == ComparationResult::Equal) {
            ok = true;
            break;
        }

        hash_value += 1;
        hash_value %= _VX_HASHTABLE_MEM_LENGTH(hash_table);
    } while (hash_table->elements[hash_value].state != HashTableBucketState::Empty);   /* Repeat until we found an empty bucket. */

    if (!ok) {
        return option_none<T>();
    }

    Option<T> return_value = option_some<T>(hash_table->elements[hash_value].value);

    hash_table->elements[hash_value].state = HashTableBucketState::Deleted;

    hash_table->num_elems--;
    return return_value;
}

template <class T, class K>
void hashtable_set_all_values(HashTable<T, K>* hash_table, T value) {
    for (usize i = 0; i < len(&hash_table->elements); i++) {
        if (hash_table->elements[i].state == HashTableBucketState::Used) {
            hash_table->elements[i].value = value;
        }
    }
}

template <class T, class K>
struct HashTableElementIterator {
    HashTable<T, K>* hash_table;
    usize current_idx;
};

template <class T, class K>
struct HashTableKeyIterator {
    HashTable<T, K>* hash_table;
    usize current_idx;
};

template <class T, class K>
HashTableElementIterator<T, K> hashtable_get_element_iter(HashTable<T, K>* hash_table) {
    HashTableElementIterator<T, K> iter;

    iter.hash_table = hash_table;
    iter.current_idx = 0;

    return iter;
}

template <class T, class K>
HashTableKeyIterator<T, K> hashtable_get_key_iter(HashTable<T, K>* hash_table) {
    HashTableKeyIterator<T, K> iter;

    iter.hash_table = hash_table;
    iter.current_idx = 0;

    return iter;
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

VX_CREATE_TO_ITER_T(VX_MACRO_ARG(template <class T, class K>), VX_MACRO_ARG(HashTable<T, K>*), VX_MACRO_ARG(HashTableElementIterator<T, K>),
    return hashtable_get_element_iter(VALUE);
)

VX_CREATE_ITER_NEXT_T(VX_MACRO_ARG(template <class T, class K>), VX_MACRO_ARG(HashTableElementIterator<T, K>), T,
    while (ITER->hash_table->elements[ITER->current_idx].state != HashTableBucketState::Used) {
        ITER->current_idx++;

        VX_ASSERT("HashTableElementIterator out of bounds!", ITER->current_idx < _VX_HASHTABLE_MEM_LENGTH(ITER->hash_table));
    }

    ITER->current_idx++;

    return &(ITER->hash_table->elements[ITER->current_idx - 1].value);
)

VX_CREATE_ITER_HAS_FINISHED_T(VX_MACRO_ARG(template <class T, class K>), VX_MACRO_ARG(HashTableElementIterator<T, K>),
    bool finish = true;

    usize tmp = ITER->current_idx;
    while (tmp < _VX_HASHTABLE_MEM_LENGTH(ITER->hash_table)) {
        if (ITER->hash_table->elements[tmp].state == HashTableBucketState::Used) {
            finish = false;
            break;
        }

        tmp++;
    }

    return finish;
)

VX_CREATE_ITER_NEXT_T(VX_MACRO_ARG(template <class T, class K>), VX_MACRO_ARG(HashTableKeyIterator<T, K>), K,
    while (ITER->hash_table->elements[ITER->current_idx].state != HashTableBucketState::Used) {
        ITER->current_idx++;

        VX_ASSERT("HashTableKeyIterator out of bounds!", ITER->current_idx < _VX_HASHTABLE_MEM_LENGTH(ITER->hash_table));
    }

    ITER->current_idx++;

    return &(ITER->hash_table->elements[ITER->current_idx - 1].key);
)

VX_CREATE_ITER_HAS_FINISHED_T(VX_MACRO_ARG(template <class T, class K>), VX_MACRO_ARG(HashTableKeyIterator<T, K>),
    bool finish = true;

    usize tmp = ITER->current_idx;
    while (tmp < _VX_HASHTABLE_MEM_LENGTH(ITER->hash_table)) {
        if (ITER->hash_table->elements[tmp].state == HashTableBucketState::Used) {
            finish = false;
            break;
        }

        tmp++;
    }

    return finish;
)

#undef _VX_HASHTABLE_MEM_LENGTH

/* EXAMPLE:
 *  int main() {
 *      vx::stream_logger_init(stdout, vx::LogMessageLevel::DEBUG);
 *      vx::allocator_stack_init();
 *
 *      VX_DEFER(vx::stream_logger_free());
 *      VX_DEFER(vx::allocator_stack_free());
 *
 *      vx::HashTable<int, const char*> hash_table = vx::hash_table_new<int, const char*>();
 *      VX_DEFER(vx::hash_table_free(&hash_table));
 *      vx::hash_table_set(&hash_table, "Hi!", 1);
 *      vx::hash_table_set(&hash_table, "Ho!", 2);
 *      vx::hash_table_set(&hash_table, "Hi!", 3);
 *      vx::hash_table_set(&hash_table, "Ho!", 4);
 *      vx::hash_table_set(&hash_table, "Hi!", 5);
 *
 *      printf("table len: %lld\n", vx::len(&hash_table));
 *      printf("%d\n", *vx::hash_table_get(&hash_table, "Hi!"));
 *      printf("%d\n", *vx::hash_table_get(&hash_table, "Ho!"));
 *
 *      vx::hash_table_remove(&hash_table, "Hi!");
 *      printf("table len: %lld\n", vx::len(&hash_table));
 *
 *      vx::HashTable<int, const char*> hash_table2 = vx::hash_table_new<int, const char*>();
 *      VX_DEFER(vx::hash_table_free(&hash_table2));
 *      vx::clone(&hash_table, &hash_table2);
 *
 *      return 0;
 *   }
*/