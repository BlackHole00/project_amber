#pragma once

#include "types.h"
#include "mem.h"
#include "instance.h"
#include "functions.h"
#include "slice.h"
#include "traits/to_string.h"

#include <cstring>

namespace vx {

/**
 * @enum LogMessageLevel
 * @brief Defines the importance level of a message to be sent.
 */
enum class LogMessageLevel {
    DEBUG,
    INFO,
    WARN,
    ERROR,
    FATAL,
    COUNT,
};

/**
 * @class Logger - INSTANCE
 * @brief Helps the user with organized logging. This struct is only a template. It is implemented in other files (see StreamLogger).
 */
struct Logger {
    /* Defines what messages should be ignored. */
    LogMessageLevel minimum_message_level;

    /* Print function. Is provied by the implementation. */
    VX_CALLBACK(void, print, LogMessageLevel message_level, const char* message);

    /* A pointer to some eventual implentation data. */
    void* log_data;
};
VX_DECLARE_INSTANCE(Logger, LOGGER_INSTANCE);

/** @brief Creates a logger that does nothing in the LOGGER_INSTANCE. */
void empty_logger_init();
/** @brief Frees the logger that does nothing in the LOGGER_INSTANCE. */
inline void empty_logger_free() {}

/**
 * @brief Logs a message.
 * @param message_level The importance level of a message.
 * @param fmt A printf style format string.
 */
void log(LogMessageLevel message_level, const char* fmt, ...);

};

VX_CREATE_TO_STRING(LogMessageLevel, 
    switch(VALUE) {
        case LogMessageLevel::DEBUG: {
            std::strncpy(BUFFER, "DEBUG", len(BUFFER));
            break;
        }
        case LogMessageLevel::INFO: {
            std::strncpy(BUFFER, "INFO", len(BUFFER));
            break;
        }
        case LogMessageLevel::WARN: {
            std::strncpy(BUFFER, "WARN", len(BUFFER));
            break;
        }
        case LogMessageLevel::ERROR: {
            std::strncpy(BUFFER, "ERROR", len(BUFFER));
            break;
        }
        case LogMessageLevel::FATAL: {
            std::strncpy(BUFFER, "FATAL", len(BUFFER));
            break;
        }
        default: {
            std::strncpy(BUFFER, "", len(BUFFER));
        }
    }
)

//#define VX_DEBUG_LOG(_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_DEBUG, _FMT, __VA_ARGS__)
//#define VX_INFO_LOG (_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_INFO,  _FMT, __VA_ARGS__)
//#define VX_WARN_LOG (_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_WARN,  _FMT, __VA_ARGS__)
//#define VX_ERROR_LOG(_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_ERROR, _FMT, __VA_ARGS__)
//#define VX_FATAL_LOG(_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_FATAL, _FMT, __VA_ARGS__)
