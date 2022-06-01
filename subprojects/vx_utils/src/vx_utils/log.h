#pragma once

#include "types.h"
#include "mem.h"
#include "instance.h"
#include "functions.h"

typedef enum {
    VX_LOGMESSAGELEVEL_DEBUG,
    VX_LOGMESSAGELEVEL_INFO,
    VX_LOGMESSAGELEVEL_WARN,
    VX_LOGMESSAGELEVEL_ERROR,
    VX_LOGMESSAGELEVEL_FATAL,
    VX_LOGMESSAGELEVEL_COUNT,
} vx_LogMessageLevel;

typedef struct {
    vx_LogMessageLevel minimum_message_level;

    VX_CALLBACK(void, print, vx_LogMessageLevel message_level, const char* message);
    void* log_data;
} vx_Logger;
VX_DECLARE_INSTANCE(vx_Logger, VX_LOGGER_INSTANCE);

void vx_empty_logger_init();
static inline void vx_empty_logger_free() {}

void vx_log(vx_LogMessageLevel message_level, const char* fmt, ...);

void vx_logmessagelevel_to_string(vx_LogMessageLevel message_level, char* buffer);

//#define VX_DEBUG_LOG(_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_DEBUG, _FMT, __VA_ARGS__)
//#define VX_INFO_LOG (_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_INFO,  _FMT, __VA_ARGS__)
//#define VX_WARN_LOG (_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_WARN,  _FMT, __VA_ARGS__)
//#define VX_ERROR_LOG(_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_ERROR, _FMT, __VA_ARGS__)
//#define VX_FATAL_LOG(_FMT, ...) vx_log(VX_LOGMESSAGELEVEL_FATAL, _FMT, __VA_ARGS__)
