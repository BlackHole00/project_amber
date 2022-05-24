#pragma once

#define VX_PANIC(_MESSAGE) vx_panic(__FILE__, __LINE__, __FUNCTION__, _MESSAGE)
#define VX_ASSERT(_MESSAGE, _EQ) { if(!(_EQ)) { VX_PANIC(_MESSAGE); } }
#define VX_CHECK(_EQ, _RET) { if (!(_EQ)) { return _RET; } }
#define VX_PANIC_EXIT_OP(_MESSAGE, _EXIT_OP) _EXIT_OP; VX_PANIC(_MESSAGE);
#define VX_ASSERT_EXIT_OP(_MESSAGE, _EQ, _EXIT_OP) { if(!(_EQ)) { VX_PANIC_EXIT_OP(_MESSAGE, _EXIT_OP); } }
#define VX_CHECK_EXIT_OP(_EQ, _RET, _EXIT_OP) { if (!(_EQ)) { _EXIT_OP; return _RET; } }
#define VX_UNIMPLEMENTED() VX_PANIC("This function has yet to be implemented!")

#ifdef _DEBUG
    #define VX_DBG_ASSERT(_MESSAGE, _EQ) VX_ASSERT(_MESSAGE, _EQ)
    #define VX_DBG_CHECK(_EQ, _RET) VX_CHECK(_EQ, _RET)
    #define VX_DBG_PANIC_EXIT_OP(_MESSAGE, _EXIT_OP) VX_PANIC_EXIT_OP(_MESSAGE, _EXIT_OP)
    #define VX_DBG_ASSERT_EXIT_OP(_MESSAGE, _EQ, _EXIT_OP) VX_ASSERT_EXIT_OP(_MESSAGE, _EQ, _EXIT_OP)
    #define VX_DBG_CHECK_EXIT_OP(_EQ, _RET, _EXIT_OP) VX_CHECK_EXIT_OP(_EQ, _RET, _EXIT_OP)
    #define VX_NULL_ASSERT(_OBJ) VX_ASSERT("Object "#_OBJ" is NULL!", _OBJ != NULL)
    #define VX_NULL_CHECK(_OBJ, _RET) VX_CHECK_EXIT_OP(_OBJ != NULL, _RET, printf("Object "#_OBJ" is NULL!\n"))
#else   /*  _RELEASE    */
    #define VX_DBG_ASSERT(...)
    #define VX_DBG_CHECK(...)
    #define VX_DBG_PANIC_EXIT_OP(...)
    #define VX_DBG_ASSERT_EXIT_OP(...)
    #define VX_DBG_CHECK_EXIT_OP(...)
    #define VX_NULL_ASSERT(...)
    #define VX_NULL_CHECK(...)
#endif

void vx_panic(char*, int, const char*, char*);

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
