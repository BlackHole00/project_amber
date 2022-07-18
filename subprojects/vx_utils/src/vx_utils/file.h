#pragma once
#include <cstdio>

#include "mem.h"
#include "slice.h"

namespace vx {
    /**
     * @brief Gets the content of a file into a string.
     * @return Returns a string containing the content of the file. Must be freed by the user. Returns nullptr if the file is not valid.
     */
    char* file_get_content(std::FILE* file, usize* len = nullptr, Allocator* allocator = nullptr);

    /**
     * @brief Gets the content of a file into a string opening the file via a file_path.
     * @return Returns a string containing the content of the file. Must be freed by the user. Returns nullptr if the file is not valid.
     */
    char* filepath_get_content(const char* file_path, usize* len = nullptr, const char* mode = "r", Allocator* allocator = nullptr);

    usize file_get_len(std::FILE* file);
    usize filepath_get_len(const char* file_path, const char* mode = "r");

    usize file_get_content_to_slice(std::FILE* file, Slice<char> buffer);
    usize filepath_get_content_to_slice(const char* file_path, Slice<char> buffer, const char* mode = "r");


};
