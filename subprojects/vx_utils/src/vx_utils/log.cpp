#include "log.h"

#include <stdio.h>
#include <stdarg.h>
#include <string.h>

namespace vx {

VX_CREATE_INSTANCE(Logger, LOGGER_INSTANCE);

void empty_logger_init() {
    LOGGER_INSTANCE.log_data = NULL;
    LOGGER_INSTANCE.minimum_message_level = LogMessageLevel::COUNT;
    LOGGER_INSTANCE.print = (void (*)(LogMessageLevel, const char*))vx::_dummy_func;

    LOGGER_INSTANCE_VALID = true;
}

void log(LogMessageLevel message_level, const char* fmt, ...) {
    if (message_level >= LOGGER_INSTANCE.minimum_message_level) {
        va_list args;
        va_start(args, fmt);

        int required_chars = vsnprintf(NULL, 0, fmt, args);
        char* buffer = vx::alloc<char>(required_chars + 1);

        vsprintf(buffer, fmt, args);

        LOGGER_INSTANCE.print(message_level, buffer);

        vx::free(buffer);
        va_end(args);
    }
}

void logmessagelevel_to_string(LogMessageLevel message_level, char* buffer) {
    switch(message_level) {
        case LogMessageLevel::DEBUG: {
            strcpy(buffer, "DEBUG");
            break;
        }
        case LogMessageLevel::INFO: {
            strcpy(buffer, "INFO");
            break;
        }
        case LogMessageLevel::WARN: {
            strcpy(buffer, "WARN");
            break;
        }
        case LogMessageLevel::ERROR: {
            strcpy(buffer, "ERROR");
            break;
        }
        case LogMessageLevel::FATAL: {
            strcpy(buffer, "FATAL");
            break;
        }
        default: {
            strcpy(buffer, "");
        }
    }
}

};