#pragma once

#define VX_CREATE_TYPE_POINTER_DEFINITION(_TYPE) typedef _TYPE* _TYPE ## _ptr

/*  Merge the name of the function and the type of the template */
#define VX_TEMPLATE_NAME(_T, _NAME) _NAME ## _ ## _T
#define VX_TEMPLATE_BODY(_T, _BODY) _BODY(_T)
#define VX_TEMPLATE_PROT(_T, _PROT) _PROT(_T)
#define VX_TEMPLATE_INL(_T, _INL )  _INL(_T)
#define VX_TEMPLATE_ELEM(_T, _ELEM) _ELEM(_T)
#define VX_TEMPLATE_CALL(_T, _NAME) VX_TEMPLATE_NAME(_T, _NAME)

#define VX_TEMPLATE_NAME_1(_T, _NAME) VX_TEMPLATE_NAME(_T, _NAME)
#define VX_TEMPLATE_BODY_1(_T, _BODY) VX_TEMPLATE_BODY(_T, _BODY)
#define VX_TEMPLATE_PROT_1(_T, _PROT) VX_TEMPLATE_PROT(_T, _PROT)
#define VX_TEMPLATE_INL_1(_T, _INL)   VX_TEMPLATE_INL(_T, _INL)
#define VX_TEMPLATE_ELEM_1(_T, _ELEM) VX_TEMPLATE_ELEM(_T, _ELEM)
#define VX_TEMPLATE_CALL_1(_T, _NAME) VX_TEMPLATE_CALL(_T, _NAME)

#define VX_TEMPLATE_NAME_2(_T, _U, _NAME) _NAME ## _ ## _T ## _ ## _U
#define VX_TEMPLATE_BODY_2(_T, _U, _BODY) _BODY(_T, _U)
#define VX_TEMPLATE_PROT_2(_T, _U, _PROT) _PROT(_T, _U)
#define VX_TEMPLATE_INL_2(_T, _U, _INL)   _INL(_T, _U)
#define VX_TEMPLATE_ELEM_2(_T, _U, _ELEM) _ELEM(_T, _U)
#define VX_TEMPLATE_CALL_2(_T, _U, _NAME) VX_TEMPLATE_NAME_2(_T, _U, _NAME)

#define VX_T(_T, _EXPR) VX_TEMPLATE_NAME(_T, _EXPR)
#define VX_T_1(_T, _EXPR) VX_TEMPLATE_NAME(_T, _EXPR)
#define VX_T_2(_T, _U, _EXPR) VX_TEMPLATE_NAME_2(_T, _U, _EXPR)

/*  EXAMPLE:
*       #define T_TEST_BD(T) T VX_TEMPLATE_NAME(T, t_test)() {      \
*           T a = 0;                                                \
*           return a;                                               \
*       }
*       #define T_TEST_PT(T) T VX_TEMPLATE_NAME(T, t_test)();
*
*       VX_TEMPLATE_PROT(i32, T_TEST_PT);
*       VX_TEMPLATE_PROT(f32, T_TEST_PT);
*
*       int main() {
*           printf("\nValue Returned from t_test_i32(VX_T(i32, t_test)): %d\nValue Returned from t_test_f32(VX_T(f32, t_test)): %f\n",
*               VX_T(i32, t_test)(), VX_T(f32, t_test)()
*           );
*
*           return 0;
*       }
*
*       VX_TEMPLATE_BODY(i32, T_TEST_BD);
*       VX_TEMPLATE_BODY(f32, T_TEST_BD);
*/
