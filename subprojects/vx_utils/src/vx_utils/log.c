#include "log.h"

#include <stdio.h>
#include <stdarg.h>
#include <string.h>

VX_CREATE_INSTANCE(vx_Logger, VX_LOGGER_INSTANCE);

void vx_empty_logger_init() {
    VX_LOGGER_INSTANCE.log_data = NULL;
    VX_LOGGER_INSTANCE.minimum_message_level = VX_LOGMESSAGELEVEL_COUNT;
    VX_LOGGER_INSTANCE.print = _vx_dummy_func;
}

void vx_log(vx_LogMessageLevel message_level, const char* fmt, ...) {
    static char buffer[1024] = { 0 };

    if (message_level >= VX_LOGGER_INSTANCE.minimum_message_level) {
        va_list args;
        va_start(args, fmt);

        int required_chars = vsnprintf(NULL, 0, fmt, args);
        char* buffer = vx_smalloc((required_chars + 1) * sizeof(char));

        vsprintf(buffer, fmt, args);

        VX_LOGGER_INSTANCE.print(message_level, buffer);

        vx_free(buffer);
        va_end(args);
    }
}

void vx_logmessagelevel_to_string(vx_LogMessageLevel message_level, char* buffer) {
    switch(message_level) {
        case VX_LOGMESSAGELEVEL_DEBUG: {
            strcpy(buffer, "DEBUG");
            break;
        }
        case VX_LOGMESSAGELEVEL_INFO: {
            strcpy(buffer, "INFO");
            break;
        }
        case VX_LOGMESSAGELEVEL_WARN: {
            strcpy(buffer, "WARN");
            break;
        }
        case VX_LOGMESSAGELEVEL_ERROR: {
            strcpy(buffer, "ERROR");
            break;
        }
        case VX_LOGMESSAGELEVEL_FATAL: {
            strcpy(buffer, "FATAL");
            break;
        }
        default: {
            strcpy(buffer, "");
        }
    }
}