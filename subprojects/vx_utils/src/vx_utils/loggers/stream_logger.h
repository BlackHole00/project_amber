#pragma once

#include <cstdio>

#include "../log.h"

namespace vx {

void stream_logger_init(std::FILE* stream, LogMessageLevel minimum_message_level);
static inline void stream_logger_free() {}

};