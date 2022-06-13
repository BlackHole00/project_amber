#include "stream_logger.h"

#include <ctime>
#include <cstring>
#include "../panic.h"

namespace vx {

static void _stream_logger_print(LogMessageLevel message_level, const char* message) {
    static char buffer[10] = {0};
    static time_t t;

    std::time(&t);

    std::FILE* stream = (std::FILE*)LOGGER_INSTANCE.log_data;

    to_string(message_level, slice_from_array<char, 10>(buffer));

    std::fprintf(stream, "[%s] (%s): %s\n", buffer, std::strtok(std::ctime(&t), "\n"), message);
}

void stream_logger_init(std::FILE* stream, LogMessageLevel minimum_message_level) {
    LOGGER_INSTANCE.log_data = stream;
    LOGGER_INSTANCE.minimum_message_level = minimum_message_level;
    LOGGER_INSTANCE.print = _stream_logger_print;

    LOGGER_INSTANCE_VALID = true;
}

static inline void stream_logger_free() {
    LOGGER_INSTANCE_VALID = false;
}

}