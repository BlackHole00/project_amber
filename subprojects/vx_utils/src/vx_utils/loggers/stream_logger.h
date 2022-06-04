#pragma once

#include <stdio.h>

#include "../log.h"

namespace vx {

void stream_logger_init(FILE* stream, LogMessageLevel minimum_message_level);
static inline void stream_logger_free() {}

};