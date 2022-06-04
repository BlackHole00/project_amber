#include "panic.h"

#include <stdio.h>
#include <stdlib.h>

#include "log.h"

namespace vx {

void panic(const char* file, int line, const char* function, const char* message) {
    //printf("Error in function %s(%s::%d): %s", function, file, line, message);
    if (LOGGER_INSTANCE_VALID) {
        vx::log(vx::LogMessageLevel::FATAL, "Error in function %s(%s::%d): %s", function, file, line, message);
    } else {
        printf("Error in function %s(%s::%d): %s", function, file, line, message);
    }

    exit(-1);
}

};
