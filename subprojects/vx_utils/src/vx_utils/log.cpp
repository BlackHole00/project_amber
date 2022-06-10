#include "log.h"

#include <cstdio>
#include <cstdarg>
#include <cstring>

#include "allocators/raw_allocator.h"

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
        std::va_list args;
        va_start(args, fmt);

        int required_chars = std::vsnprintf(NULL, 0, fmt, args);

        char* buffer;
        if (!ALLOCATOR_STACK_INSTANCE_VALID) {
            if (!RAW_ALLOCATOR_INSTANCE_VALID) {
                raw_allocator_init();
            }

            buffer = vx::alloc<char>(required_chars + 1, &RAW_ALLOCATOR_INSTANCE);
        } else {
            buffer = vx::alloc<char>(required_chars + 1);
        }

        std::vsprintf(buffer, fmt, args);

        LOGGER_INSTANCE.print(message_level, buffer);

        if (!ALLOCATOR_STACK_INSTANCE_VALID) {
            vx::free(buffer, &RAW_ALLOCATOR_INSTANCE);
        } else {
            vx::free(buffer);
        }

        va_end(args);
    }
}

void logmessagelevel_to_string(LogMessageLevel message_level, char* buffer) {
    switch(message_level) {
        case LogMessageLevel::DEBUG: {
            std::strcpy(buffer, "DEBUG");
            break;
        }
        case LogMessageLevel::INFO: {
            std::strcpy(buffer, "INFO");
            break;
        }
        case LogMessageLevel::WARN: {
            std::strcpy(buffer, "WARN");
            break;
        }
        case LogMessageLevel::ERROR: {
            std::strcpy(buffer, "ERROR");
            break;
        }
        case LogMessageLevel::FATAL: {
            std::strcpy(buffer, "FATAL");
            break;
        }
        default: {
            std::strcpy(buffer, "");
        }
    }
}

};