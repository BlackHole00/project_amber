package vx_lib_gfx

when #config(MODERN_OPENGL, false) do MODERN_OPENGL :: true
else do MODERN_OPENGL :: false

INVALID_HANDLE :: 0

MODEL_UNIFORM_NAME :: "u_model"
VIEW_UNIFORM_NAME :: "u_view"
PROJ_UNIFORM_NAME :: "u_proj"
SKYBOX_UNIFORM_NAME :: "u_skybox"