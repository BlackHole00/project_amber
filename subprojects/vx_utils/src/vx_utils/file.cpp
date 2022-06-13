#include "file.h"

#include "utils.h"
#include "mem.h"

namespace vx {

char* file_get_content(std::FILE* file, Allocator* allocator) {
    /*  Check if the file is valid  */
    VX_NULL_CHECK(file, nullptr);

    VX_VALIDATE_ALLOCATOR(allocator);

    char* res = nullptr;

    /*  Get the initial position of the file. The user may still want to use the file.  */
    std::fpos_t intial_point_in_file;
    std::fgetpos(file, &intial_point_in_file);
    std::rewind(file);

    /*  Get the file length. If the length is 0, then return NULL.  */
    i32 file_len = 0;
    char c;
    while ((c = std::fgetc(file)) != EOF) {
        file_len++;
    }
    VX_CHECK(file_len > 0, NULL)

    /*  Allocate the needed space. */
    res = alloc<char>(file_len + 1);
    res[file_len] = '\0';
    std::rewind(file);

    /*  Get all the characters. */
    u32 i = 0;
    while ((c = std::fgetc(file)) != EOF) {
        res[i++] = c;
    }

    /*  Restore the initial position*/
    std::fsetpos(file, &intial_point_in_file);

    return res;
}

char* filepath_get_content(const char* file_path, Allocator* allocator) {
    std::FILE* file = std::fopen(file_path, "r");
    VX_CHECK(file != NULL, NULL);

    char* res = file_get_content(file, allocator);

    std::fclose(file);

    return res;
}

};
