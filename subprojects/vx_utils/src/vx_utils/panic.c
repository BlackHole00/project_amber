#include "panic.h"

#include <stdio.h>
#include <stdlib.h>

#include "log.h"

void vx_panic(char* file, int line, const char* function, char* message) {
    //printf("Error in function %s(%s::%d): %s", function, file, line, message);
    if (VX_LOGGER_INSTANCE_VALID) {
        vx_log(VX_LOGMESSAGELEVEL_FATAL, "Error in function %s(%s::%d): %s", function, file, line, message);
    } else {
        printf("Error in function %s(%s::%d): %s", function, file, line, message);
    }

    exit(-1);
}
