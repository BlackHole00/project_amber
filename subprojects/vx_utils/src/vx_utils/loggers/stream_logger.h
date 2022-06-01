#pragma once

#include <stdio.h>

#include "../log.h"

void vx_stream_logger_init(FILE* stream, vx_LogMessageLevel minimum_message_level);
static inline void vx_stream_logger_free() {}