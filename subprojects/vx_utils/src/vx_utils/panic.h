#pragma once

#include "macro.h"

/** @brief Halts the program with a message. */
#define VX_PANIC(_MESSAGE) vx::panic(__FILE__, __LINE__, __FUNCTION__, _MESSAGE)
/** @brief Halts the program with a message if a condition is not satisfied. */
#define VX_ASSERT(_MESSAGE, _EQ) { if(!(_EQ)) { VX_PANIC(_MESSAGE); } }
/** @brief Returns _RET if a condition is not satisfied. */
#define VX_CHECK(_EQ, _RET) { if (!(_EQ)) { return _RET; } }
/** @brief Halts the program with a message and executing a function. */
#define VX_PANIC_EXIT_OP(_MESSAGE, _EXIT_OP) _EXIT_OP; VX_PANIC(_MESSAGE);
/** @brief Halts the program with a message and executing a function if a condition is not satisfied. */
#define VX_ASSERT_EXIT_OP(_MESSAGE, _EQ, _EXIT_OP) { if(!(_EQ)) { VX_PANIC_EXIT_OP(_MESSAGE, _EXIT_OP); } }
/** @brief Returns _RET and executes a function if a condition is not satisfied. */
#define VX_CHECK_EXIT_OP(_EQ, _RET, _EXIT_OP) { if (!(_EQ)) { _EXIT_OP; return _RET; } }
/** @brief Halts the program if this instrution is met. Should only be used for not-yet-implemented functionality. */
#define VX_UNIMPLEMENTED() VX_PANIC("This function has yet to be implemented!")

#define VX_NULL_ASSERT(_OBJ) VX_ASSERT(VX_MACRO_ARG("Object "#_OBJ" is NULL!"), VX_MACRO_ARG(_OBJ != NULL));
#define VX_NULL_CHECK(_OBJ, _RET) VX_CHECK_EXIT_OP(VX_MACRO_ARG(_OBJ != NULL), VX_MACRO_ARG(_RET), VX_MACRO_ARG(printf("Object "#_OBJ" is NULL!\n")));

/* Debug variants of the macros above. These do nothing in release mode. */
#ifdef _DEBUG
    #define VX_DBG_ASSERT(_MESSAGE, _EQ) VX_ASSERT(_MESSAGE, _EQ)
    #define VX_DBG_CHECK(_EQ, _RET) VX_CHECK(_EQ, _RET)
    #define VX_DBG_PANIC_EXIT_OP(_MESSAGE, _EXIT_OP) VX_PANIC_EXIT_OP(_MESSAGE, _EXIT_OP)
    #define VX_DBG_ASSERT_EXIT_OP(_MESSAGE, _EQ, _EXIT_OP) VX_ASSERT_EXIT_OP(_MESSAGE, _EQ, _EXIT_OP)
    #define VX_DBG_CHECK_EXIT_OP(_EQ, _RET, _EXIT_OP) VX_CHECK_EXIT_OP(_EQ, _RET, _EXIT_OP)
#else   /*  _RELEASE    */
    #define VX_DBG_ASSERT(...)
    #define VX_DBG_CHECK(...)
    #define VX_DBG_PANIC_EXIT_OP(...)
    #define VX_DBG_ASSERT_EXIT_OP(...)
    #define VX_DBG_CHECK_EXIT_OP(...)
#endif

namespace vx {

/**
 * @brief Halts the program providing an error message.
 * @param file The .c file name of the calling location.
 * @param line The line number of the calling location.
 * @param function The function name of the calling location.
 * @param message The crash message.
 */
void panic(const char* file, int line, const char* function, const char* message);

};

/*  EXAMPLE:
*       int main() {
*           int a = 0;
*           a += 1;
*           VX_ASSERT("a is not 1!!!", a == 1);
*
*           int b = 3;
*           if (b == 4) {
*             VX_PANIC("b is 4!!!");
*           }
*
*           int c = 100;
*           //  if c != 100 then return -1
*           VX_CHECK(c == 100, -1);
*       }
*/
