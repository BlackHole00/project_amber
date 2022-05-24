#include "vx_file.h"
#include "vx_utils.h"

char* vx_file_get_content(FILE* file) {
    /*  Check if the file is valid  */
    VX_NULL_CHECK(file, NULL);

    char* res;

    /*  Get the initial position of the file. The user may still want to use the file.  */
    fpos_t intial_point_in_file;
    fgetpos(file, &intial_point_in_file);
    rewind(file);

    /*  Get the file length. If the length is 0, then return NULL.  */
    i32 file_len = 0;
    char c;
    while ((c = fgetc(file)) != EOF) {
        file_len++;
    }
    VX_CHECK(file_len > 0, NULL)

    /*  Allocate the needed space. */
    res = vx_smalloc((file_len + 1) * sizeof(char));
    res[file_len] = '\0';
    rewind(file);

    /*  Get all the characters. */
    u32 i = 0;
    while ((c = fgetc(file)) != EOF) {
        res[i++] = c;
    }

    /*  Restore the initial position*/
    fsetpos(file, &intial_point_in_file);

    return res;
}

char* vx_filepath_get_content(const char* file_path) {
    FILE* file = fopen(file_path, "r");
    VX_CHECK(file != NULL, NULL);

    char* res = vx_file_get_content(file);

    fclose(file);

    return res;
}
