#pragma once

#include <cstdio>

#include "../log.h"

namespace vx {

/**
 * The StreamLogger is a Logger implementation that permits to log messages into a 
 * stream (that can be a file or stdout).
 * @brief Initializes a StreamLogger into the LOGGER_INSTANCE.
 */
void stream_logger_init(std::FILE* stream, LogMessageLevel minimum_message_level);

/**
 * @brief Deinitializes the StreamLogger.
 */
static inline void stream_logger_free();

};