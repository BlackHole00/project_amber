#pragma once

#define VX_CONCAT(_T, _NAME) _NAME ## _ ## _T

#define VX_CREATE_TYPE_POINTER_DEFINITION(_TYPE) typedef _TYPE* _TYPE ## _ptr


#define VX_MACRO_ARG(...) __VA_ARGS__
#define COMMA ,

