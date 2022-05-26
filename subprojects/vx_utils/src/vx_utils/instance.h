#pragma once

#include "types.h"

#define VX_DECLARE_INSTANCE(_TYPE, _NAME) extern _TYPE _NAME; extern bool _NAME##_VALID;
#define VX_CREATE_INSTANCE(_TYPE, _NAME) _TYPE _NAME; bool _NAME##_VALID = false;