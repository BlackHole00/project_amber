#include "stream_logger.h"

#include <time.h>
#include <string.h>
#include "../panic.h"

static void _stream_logger_print(vx_LogMessageLevel message_level, const char* message) {
    static char buffer[10] = {0};
    static time_t t;

    time(&t);

    FILE* stream = VX_LOGGER_INSTANCE.log_data;
    vx_logmessagelevel_to_string(message_level, buffer);

    fprintf(stream, "[%s] (%s): %s\n", buffer, strtok(ctime(&t), "\n"), message);
}

void vx_stream_logger_init(FILE* stream, vx_LogMessageLevel minimum_message_level) {
    VX_LOGGER_INSTANCE.log_data = stream;
    VX_LOGGER_INSTANCE.minimum_message_level = minimum_message_level;
    VX_LOGGER_INSTANCE.print = _stream_logger_print;

    VX_LOGGER_INSTANCE_VALID = true;
}