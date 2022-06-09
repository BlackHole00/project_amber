#pragma once

namespace vx {
    void _dummy_func();
};

#define VX_CALLBACK(_RETURN_TYPE, _FN_NAME, ...) _RETURN_TYPE(*_FN_NAME)(__VA_ARGS__);

#define VX_SAFE_FUNC_PTR(_PTR) (_PTR == NULL ? (decltype(_PTR))vx::_dummy_func : (decltype(_PTR))_PTR)
