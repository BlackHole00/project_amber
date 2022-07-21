#pragma once

#define VX_EXPLICIT_CAST(_TYPE, _NAME) explicit operator _TYPE () const { return _NAME; }\
    explicit operator _TYPE& () { return _NAME; }\
    explicit operator const _TYPE& () const { return _NAME; }\
    explicit operator _TYPE* () { return &_NAME; }\
    explicit operator const _TYPE* () const { return &_NAME; }

#define VX_IMPLICIT_CAST(_TYPE, _NAME) operator _TYPE () const { return _NAME; }\
    operator _TYPE& () { return _NAME; }\
    operator const _TYPE& () const { return _NAME; }\
    operator _TYPE* () { return &_NAME; }\
    operator const _TYPE* () const { return &_NAME; }
