#include "log.h"

#include <cstdio>

#include "allocators/raw_allocator.h"

namespace vx {

VX_CREATE_INSTANCE(Logger, LOGGER_INSTANCE);

void empty_logger_init() {
    LOGGER_INSTANCE.log_data = NULL;
    LOGGER_INSTANCE.minimum_message_level = LogMessageLevel::COUNT; /* Do not accept any message. */
    LOGGER_INSTANCE.print = (void (*)(LogMessageLevel, const char*))vx::_dummy_func; /* Do nothing. */

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

        for (int i = required_chars; i >= 0; i--) {
            if (buffer[i] == '\n') {
                buffer[i] = '\0';
            }
            else if (buffer[i] != '\0') {
                break;
            }
        }

        LOGGER_INSTANCE.print(message_level, buffer);

        if (!ALLOCATOR_STACK_INSTANCE_VALID) {
            vx::free(buffer, &RAW_ALLOCATOR_INSTANCE);
        } else {
            vx::free(buffer);
        }

        va_end(args);
    }
}

};