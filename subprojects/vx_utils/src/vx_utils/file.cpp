#include "file.h"

#include "utils.h"
#include "mem.h"

namespace vx {

char* file_get_content(std::FILE* file, usize* len, Allocator* allocator) {
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
    VX_CHECK(file_len > 0, NULL);

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

    if (len != nullptr) {
        *len = file_len;
    }

    return res;
}

char* filepath_get_content(const char* file_path, usize* len, const char* mode, Allocator* allocator) {
    std::FILE* file = std::fopen(file_path, mode);
    VX_CHECK(file != nullptr, nullptr);

    char* res = file_get_content(file, len, allocator);

    std::fclose(file);

    return res;
}

usize file_get_len(std::FILE* file) {
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

    /*  Restore the initial position*/
    std::fsetpos(file, &intial_point_in_file);

    return file_len;
}

usize filepath_get_len(const char* file_path, const char* mode) {
    std::FILE* file = std::fopen(file_path, mode);
    VX_CHECK(file != nullptr, 0);

    usize file_len = file_get_len(file);

    std::fclose(file);

    return file_len;
}

usize file_get_content_to_slice(std::FILE* file, Slice<char> buffer) {
    /*  Check if the file is valid  */
    VX_NULL_CHECK(file, 0);

    /*  Get the initial position of the file. The user may still want to use the file.  */
    std::fpos_t intial_point_in_file;
    std::fgetpos(file, &intial_point_in_file);
    std::rewind(file);

    /*  Get all the characters. */
    char c;
    u32 i = 0;
    while (i < len(buffer) && (c = std::fgetc(file)) != EOF) {
        buffer[i++] = c;
    }

    /*  Restore the initial position*/
    std::fsetpos(file, &intial_point_in_file);

    return i;
}

usize filepath_get_content_to_slice(const char* file_path, Slice<char> buffer, const char* mode) {
    std::FILE* file = std::fopen(file_path, mode);
    VX_CHECK(file != nullptr, 0);

    usize file_len = file_get_len(file);

    std::fclose(file);

    return file_len;
}

};
