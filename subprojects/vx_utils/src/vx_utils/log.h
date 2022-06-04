#pragma once

#include "types.h"
#include "mem.h"
#include "instance.h"
#include "functions.h"

namespace vx {

enum class LogMessageLevel {
    DEBUG,
    INFO,
    WARN,
    ERROR,
    FATAL,
    COUNT,
};

struct Logger {
    LogMessageLevel minimum_message_level;

    VX_CALLBACK(void, print, LogMessageLevel message_level, const char* message);
    void* log_data;
};
VX_DECLARE_INSTANCE(Logger, LOGGER_INSTANCE);

void empty_logger_init();
static inline void empty_logger_free() {}

void log(LogMessageLevel message_level, const char* fmt, ...);

void logmessagelevel_to_string(LogMessageLevel message_level, char* buffer);

};

//#define VX_DEBUG_LOG(_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_DEBUG, _FMT, __VA_ARGS__)
//#define VX_INFO_LOG (_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_INFO,  _FMT, __VA_ARGS__)
//#define VX_WARN_LOG (_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_WARN,  _FMT, __VA_ARGS__)
//#define VX_ERROR_LOG(_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_ERROR, _FMT, __VA_ARGS__)
//#define VX_FATAL_LOG(_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_FATAL, _FMT, __VA_ARGS__)
