
package main

import "core:fmt"
import "core:io"
import "core:os"

LINE_MAX :: 16 * CHAR_SIZE.x
CHAR_SIZE : [2]int : { 6, 8 }

main :: proc() {
    x_count := 0
    y_count := 0

    fd, _ := os.open("../res/vx_lib/textures/font_atlas.csv", os.O_CREATE | os.O_WRONLY | os.O_TRUNC)
    w := io.to_writer(os.stream_from_handle(fd))

    for i in 0..<256 {
        str := fmt.aprint(args = {
            "char_", i, ", ", x_count, ", ", y_count, ", ", CHAR_SIZE, ", ", CHAR_SIZE, "\n",
        }, sep = "")
        defer delete(str)

        io.write_string(w, str)

        if i >= 33 && i < 127 && i != 34 {
            str2 := fmt.aprint(args = {
                "\"", (rune)(i), "\", ", x_count, ", ", y_count, ", ", CHAR_SIZE, ", ", CHAR_SIZE, "\n",
            }, sep = "")
            defer delete(str2)

            io.write_string(w, str2)
        } else if i == 34 {
            str2 := fmt.aprint(args = {
                "\"\"", (rune)(i), "\", ", x_count, ", ", y_count, ", ", CHAR_SIZE, ", ", CHAR_SIZE, "\n",
            }, sep = "")
            defer delete(str2)

            io.write_string(w, str2)
        }

        x_count += CHAR_SIZE.x
        if x_count >= LINE_MAX {
            x_count = 0
            y_count += CHAR_SIZE.y
        }
    }

    os.close(fd)
}