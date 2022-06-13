#pragma once
#include <cstdio>

#include "mem.h"

namespace vx {
    /**
     * @brief Gets the content of a file into a string.
     * @return Returns a string containing the content of the file. Must be freed by the user. Returns nullptr if the file is not valid.
     */
    char* file_get_content(std::FILE* file, Allocator* allocator = nullptr);

    /**
     * @brief Gets the content of a file into a string opening the file via a file_path.
     * @return Returns a string containing the content of the file. Must be freed by the user. Returns nullptr if the file is not valid.
     */
    char* filepath_get_content(const char* file_path, Allocator* allocator = nullptr);
};
