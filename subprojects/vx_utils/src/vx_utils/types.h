#pragma once
#include <cstdint>

typedef std::uint8_t byte;
typedef std::uint8_t u8;
typedef std::uint16_t u16;
typedef std::uint32_t u32;
typedef std::uint64_t u64;

typedef std::int8_t i8;
typedef std::int16_t i16;
typedef std::int32_t i32;
typedef std::int64_t i64;

typedef float f32;
typedef double f64;

typedef std::size_t usize;

#ifdef __ssize_t_defined
typedef ssize_t isize;
#endif

typedef char* rawstr;
