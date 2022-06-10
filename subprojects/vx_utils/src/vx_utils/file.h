#pragma once
#include <cstdio>

namespace vx {
    char* file_get_content(std::FILE*);
    char* filepath_get_content(const char*);
};
