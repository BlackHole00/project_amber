#pragma once

#include "../types.h"
#include <cstring>

namespace vx {

/**
 * @enum ComparationResult
 * @brief Describes the result of a comparation between two values.
 */
enum class ComparationResult {
    Greater,
    Equal,
    Lesser
};

};

#define VX_CREATE_COMPARE(_TYPE, ...) namespace vx {                \
inline ComparationResult compare(_TYPE V1, _TYPE V2) {              \
    __VA_ARGS__;                                                    \
}                                                                   \
};

#define VX_CREATE_COMPARE_T(_TEMPLATE_DEF, _TYPE, ...) namespace vx {  \
_TEMPLATE_DEF                                                       \
inline ComparationResult hash(_TYPE V1, _TYPE V2) {                 \
    __VA_ARGS__;                                                    \
}                                                                   \
};

VX_CREATE_COMPARE(const char*,
    int res = std::strcmp(V1, V2);

    if (res > 0) {
        return ComparationResult::Greater;
    }
    if (res == 0) {
        return ComparationResult::Equal;
    }
    if (res < 0) {
        return ComparationResult::Lesser;
    }
    return ComparationResult::Equal;
)
