#include "stream_logger.h"

#include <time.h>
#include <string.h>
#include "../panic.h"

namespace vx {

static void _stream_logger_print(LogMessageLevel message_level, const char* message) {
    static char buffer[10] = {0};
    static time_t t;

    time(&t);

    FILE* stream = (FILE*)LOGGER_INSTANCE.log_data;
    logmessagelevel_to_string(message_level, buffer);

    fprintf(stream, "[%s] (%s): %s\n", buffer, strtok(ctime(&t), "\n"), message);
}

void stream_logger_init(FILE* stream, LogMessageLevel minimum_message_level) {
    LOGGER_INSTANCE.log_data = stream;
    LOGGER_INSTANCE.minimum_message_level = minimum_message_level;
    LOGGER_INSTANCE.print = _stream_logger_print;

    LOGGER_INSTANCE_VALID = true;
}

}