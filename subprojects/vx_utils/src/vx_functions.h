#pragma once
#include <vx_template.h>
void _vx_dummy_func();


#define VX_CALLBACK(_FN_NAME, _RETURN_TYPE, ...) _RETURN_TYPE(*_FN_NAME)();

#ifdef VX_DO_NOT_USE_TYPEOF
#define VX_SAFE_FUNC_PTR(_PTR) (_PTR == NULL ? _vx_dummy_func : _PTR)
#else
#define VX_SAFE_FUNC_PTR(_PTR) (_PTR == NULL ? _vx_dummy_func : (__typeof__(_PTR))_PTR)
#endif

/*  EXAMPLE:
*       int add_fi(f32 a, i32 b) {
*           return b + a;
*       }
*
*       int main() {
*           //  VX_CALLBACK is only for readability of code. The type is still void(*)().
*           VX_CALLBACK(f32, i32) function = add_fi;
*           printf("Calling add_fi via callback: %d\n", add_fi(10.0f, 10));
*
*           VX_CALLBACK(f32, i32) invalid_fn = NULL;
*           //  The next will crash the program if uncommented.
*           //  invalid_fn();   //  CRASH!!!
*
*           //  VX_SAFE_FUNC_PTR turns that function into a callable function that is safe
*           invalid_fn = VX_SAFE_FUNC_PTR(invalid_fn);
*           invalid_fn();   //  Now invalid_fn is valid!
*       }
*/